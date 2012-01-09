package com.cinder.common.security 
{
	import caurina.transitions.AuxFunctions;
	import com.adobe.crypto.SHA1;
	import com.adobe.webapis.URLLoaderBase;
	import com.facebook.graph.data.FacebookAuthResponse;
	import com.facebook.graph.data.FacebookSession;
	import com.facebook.graph.Facebook;
	import com.junkbyte.console.Cc;
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	/**
	 * ...
	 * @author Jed Lang
	 */
	public class Credentials extends EventDispatcher
	{
		//Singleton
		private static var _instance:Credentials = new Credentials();
		public static function getInstance(): Credentials
		{
			return _instance;
		}
		public function Credentials()
		{
			if (_instance) throw new Error("Credentials can only be accessed through Credentials.getInstance()");
		}
		
		
		//Static variables
		private static var _currentSession:Session;
		public static function get currentSession():Session { return _currentSession; }
		public static var disconnected:Boolean = false;		//Set to true immediately after a disconnection occurs
		
		
		//Event constants
		public static const LOGIN_CONNECT:String = "LoginConnect";
		public static const LOGIN_SUCCESS:String = "LoginSuccess";
		public static const LOGIN_FAILURE:String = "LoginFailure";
		
		//Other constants
		private static const NumbersOnlyPattern:RegExp = /\d+/;
		public static const FinalUsernamePattern:RegExp = /((?=.*[a-zA-Z])[a-zA-Z0-9-_\+!@#\$%\^&\*]*)/;
		public static const FinalPasswordPattern:RegExp = /((?=.*[\d])(?=.*[a-zA-Z]))/;
		public static const UsernameRestrict:String = "(a-zA-Z0-9\-_+!@#$%\^&*";
		public static const PasswordRestrict:String = "(a-zA-Z0-9\-_+!@#$%\^&*";
		
		
		private var _fbAppID:String = null;
		private var _loginUrl:String = "login.php";
		private var _newUserUrl:String = "register.php";
		private var _checkAccountUrl:String = "checkAccount.php";
		private var _initialized:Boolean = false;		//This is used to ensure that Init() is called before any other functions
		private var _waitingForServer:Boolean = false;	//This is true when Credentials is in a state of awaiting a response from the server.
		private var _activeLoader:URLLoader;			//When Credentials is loading data, this is the URLLoader that was used to request it.
		
		
		//This must be called before any other functions to allow state to be set
		public function Init(fbAppId:String, loginUrl:String=null, newUserUrl:String=null, checkAccountUrl:String=null):void
		{
			_fbAppID = fbAppId;	//This is checked for FB calls to see if they should even try or not
			if (loginUrl)
				_loginUrl = loginUrl;
			if (newUserUrl)
				_newUserUrl = newUserUrl;
			if (checkAccountUrl)
				_checkAccountUrl = checkAccountUrl;
			
			Cc.log("Initializing Facebook");
			Facebook.init(_fbAppID, FBInit_Handler);
			_initialized = true;
		}
		
		
		//This function must remain private as it doesn't contain any checks!
		//Returns whether the request was successfully made or not
		private function CheckForAccount(username:String, callback:Function):Boolean
		{
			//Initial filters
			var actualUsername:String = username.toLowerCase();
			
			//Setup request
			var variables:URLVariables = new URLVariables();
			variables.username = actualUsername;
			
			var varSend:URLRequest = new URLRequest(_checkAccountUrl);
			varSend.method = URLRequestMethod.POST;
			varSend.data = variables;
			
			_activeLoader = new URLLoader();
			_activeLoader.dataFormat = URLLoaderDataFormat.VARIABLES;
			
			_activeLoader.addEventListener(Event.COMPLETE, callback, false, 0, true);
			_activeLoader.addEventListener(HTTPStatusEvent.HTTP_STATUS, internalLoginHttpStatusHandler, false, 0, true);
			_activeLoader.addEventListener(IOErrorEvent.IO_ERROR, internalLoginIOErrorHandler, false, 0, true);
			_activeLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, internalLoginSecurityErrorHandler, false, 0, true);
			
			try
			{
				_waitingForServer = true;
				_activeLoader.load(varSend);
			}
			catch(ex:Error)
			{
				return false;
			}
			return true;
		}
		
		
		// Returns whether the request has been accepted for handling.
		// If this returns false, there is already a request being handled,
		// or Credentials hasn't been initialized yet.
		public function NewUser(username:String, password:String) : Boolean
		{
			//Internal checks
			if (!_initialized || _waitingForServer)
				return false;
			
			return NewUser_Internal(username, password, true);
		}
		private function NewUser_Internal(username:String, password:String, doChecks:Boolean): Boolean
		{
			//Initial filters
			var actualUsername:String = username.toLowerCase();
			
			//This allows us to avoid collisions in the database because FB will ALWAYS submit
			//usernames and passwords that are invalid for normal signups to use.
			if (doChecks)
			{
				//Checks
				var usernameError:String = ValidateUsername(actualUsername);
				if (usernameError != "")
				{
					dispatchEvent(new LoginEvent(LOGIN_FAILURE, usernameError));
					return true;
				}
				var passwordError:String = ValidatePassword(password);
				if (passwordError != "")
				{
					dispatchEvent(new LoginEvent(LOGIN_FAILURE, passwordError));
					return true;
				}
				var crossCheckError:String = ValidateUsernameVsPassword(actualUsername, password);
				if (crossCheckError != "")
				{
					dispatchEvent(new LoginEvent(LOGIN_FAILURE, crossCheckError));
					return true;
				}
			}
			
			//Setup request
			var variables:URLVariables = new URLVariables();
			variables.username = actualUsername;
			variables.password = EncryptPassword(password);
			
			var varSend:URLRequest = new URLRequest(_newUserUrl);
			varSend.method = URLRequestMethod.POST;
			varSend.data = variables;
			
			_activeLoader = new URLLoader();
			_activeLoader.dataFormat = URLLoaderDataFormat.VARIABLES;
			
			_activeLoader.addEventListener(Event.COMPLETE, internalLoginCompleteHandler, false, 0, true);
			_activeLoader.addEventListener(Event.OPEN, internalLoginConnectedHandler, false, 0, true);
			_activeLoader.addEventListener(HTTPStatusEvent.HTTP_STATUS, internalLoginHttpStatusHandler, false, 0, true);
			_activeLoader.addEventListener(IOErrorEvent.IO_ERROR, internalLoginIOErrorHandler, false, 0, true);
			_activeLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, internalLoginSecurityErrorHandler, false, 0, true);
			
			try
			{
				_waitingForServer = true;
				_activeLoader.load(varSend);
			}
			catch(ex:Error)
			{
				dispatchEvent(new LoginEvent(LOGIN_FAILURE, "Error connecting to server"));
				return true;
			}
			
			return true;
		}
		
		// Returns whether the request has been accepted for handling.
		// If this returns false, there is already a request being handled,
		// or Credentials hasn't been initialized yet.
		public function Login(username:String, password:String) : Boolean
		{
			//Internal checks
			if (!_initialized || _waitingForServer)
				return false;
			
			//Initial filters
			var actualUsername:String = username.toLowerCase();
			
			//Setup request
			var variables:URLVariables = new URLVariables();
			variables.username = actualUsername;
			variables.password = EncryptPassword(password);
			
			var varSend:URLRequest = new URLRequest(_loginUrl);
			varSend.method = URLRequestMethod.POST;
			varSend.data = variables;
			
			_activeLoader = new URLLoader();
			_activeLoader.dataFormat = URLLoaderDataFormat.VARIABLES;
			
			_activeLoader.addEventListener(Event.COMPLETE, internalLoginCompleteHandler, false, 0, true);
			_activeLoader.addEventListener(Event.OPEN, internalLoginConnectedHandler, false, 0, true);
			_activeLoader.addEventListener(HTTPStatusEvent.HTTP_STATUS, internalLoginHttpStatusHandler, false, 0, true);
			_activeLoader.addEventListener(IOErrorEvent.IO_ERROR, internalLoginIOErrorHandler, false, 0, true);
			_activeLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, internalLoginSecurityErrorHandler, false, 0, true);
			
			try
			{
				_waitingForServer = true;
				_activeLoader.load(varSend);
			}
			catch(ex:Error)
			{
				dispatchEvent(new LoginEvent(LOGIN_FAILURE, "Error connecting to server"));
				return true;
			}
			
			return true;
		}
		
		// Returns whether the request has been accepted for handling.
		// If this returns false, there is already a request being handled,
		// or Credentials hasn't been initialized yet.
		public function FBLogin():Boolean
		{
			if (!_initialized || !_fbAppID)
				return false;
			
			Facebook.login(FBLogin_Handler);
			return true;
		}
		
		
		//******************************************************
		//
		//					 LOGIN CALLBACKS
		//
		//******************************************************
		private function internalLoginCompleteHandler(e:Event):void 
		{
			var vars:URLVariables = new URLVariables(e.target.data);
			Reset();
			if (vars.Success == 1)
			{
				_currentSession = new Session(vars.SessionID, vars.Username);
				
				//Only dispatch the event if it's a normal session, as the
				//Facebook session requires an additional piece of data first
				if (NumbersOnlyPattern.test(vars.Username))
					Facebook.api("/me", fbGetMe_Handler);
				else
				{
					disconnected = false;
					dispatchEvent(new LoginEvent(LOGIN_SUCCESS));
				}
			}
			else
				dispatchEvent(new LoginEvent(LOGIN_FAILURE, vars.Error));
		}
		private function internalLoginConnectedHandler(e:Event):void 
		{
			dispatchEvent(new LoginEvent(LOGIN_CONNECT));
		}
		private function internalLoginHttpStatusHandler(e:HTTPStatusEvent):void 
		{
			//Status Codes as per http://www.w3.org/Protocols/rfc2616/rfc2616-sec10.html
			if ((e.status >= 300 && e.status <= 307) ||
				(e.status >= 400 && e.status <= 401) ||
				(e.status >= 403 && e.status <= 417) ||
				(e.status >= 500 && e.status <= 505))
			{
				Reset();
				dispatchEvent(new LoginEvent(LOGIN_FAILURE, e.status.toString()));
			}
			//Ignore everything else
		}
		private function internalLoginIOErrorHandler(e:IOErrorEvent):void 
		{
			Reset();
			dispatchEvent(new LoginEvent(LOGIN_FAILURE, e.text));
		}
		private function internalLoginSecurityErrorHandler(e:SecurityErrorEvent):void 
		{
			Reset();
			dispatchEvent(new LoginEvent(LOGIN_FAILURE, e.text));
		}
		
		
		//******************************************************
		//
		//				        FB HELPERS
		//
		//******************************************************
		private function FBInit_Handler(authResponse:Object, nothing:Object):void 
		{
			//User already logged into facebook
			if (authResponse)
			{
				//User has already authorized this app
				Cc.log("Facebook init successful");
				var fbAuthResponse:FacebookAuthResponse = authResponse as FacebookAuthResponse;
				var username:String = fbAuthResponse.uid;
				if (!CheckForAccount(username, FBAcctExists_Handler))
				{
					dispatchEvent(new LoginEvent(LOGIN_FAILURE, "Error checking for account (FBInit_Handler)"));
				}
			}
			else
			{
				//User hasn't authorized this app yet
				Cc.info("Facebook init failed");
			}
		}
		private function FBLogin_Handler(authResponse:Object, nothing:Object):void 
		{
			if (authResponse)
			{
				//User logged in
				Cc.log("Facebook login successful");
				var fbAuthResponse:FacebookAuthResponse = authResponse as FacebookAuthResponse;
				var username:String = fbAuthResponse.uid;
				if (!CheckForAccount(username, FBAcctExists_Handler))
				{
					dispatchEvent(new LoginEvent(LOGIN_FAILURE, "Error checking for account (FBLogin_Handler)"));
				}
			}
			else
			{
				//User cancelled
				Cc.info("Facebook login failed");
			}
		}
		private function FBAcctExists_Handler(e:Event):void 
		{
			var vars:URLVariables = new URLVariables(e.target.data);
			Reset();
			if (vars.Success == 1)
			{
				//The request was successful, get the result
				var username:String = vars.Username;
				var password:String = SHA1.hashToBase64(SHA1.hash(username));
				if (vars.Result == 0)
				{
					//The account doesn't exist, create it
					if (!NewUser_Internal(username, password, false))
						dispatchEvent(new LoginEvent(LOGIN_FAILURE, "The client is disallowing new users at this time"));
				}
				else
				{
					//The account exists, login using it
					if (!Login(username, password))
						dispatchEvent(new LoginEvent(LOGIN_FAILURE, "The client is disallowing logins at this time"));
				}
			}
			else
				//There was an error processing the request
				dispatchEvent(new LoginEvent(LOGIN_FAILURE, vars.Error));
		}
		private function fbGetMe_Handler(result:Object, fail:Object):void 
		{
			if (result)
			{
				//"/me" object retrieved successfully
				Credentials._currentSession.setFacebookMe(result);
				disconnected = false;
				dispatchEvent(new LoginEvent(LOGIN_SUCCESS));
			}
			else
				//Error when retrieving "/me" object
				dispatchEvent(new LoginEvent(LOGIN_FAILURE, "Failed to retrieve Facebook user information"));
		}
		
		
		//******************************************************
		//
		//				     OTHER FUNCTIONS
		//
		//******************************************************
		//This will cancel a pending request to allow another to be made
		public function Reset():void
		{
			if (!_initialized)
				return;
			
			if (_activeLoader)
			{
				try
				{
					_activeLoader.close();
				}
				catch (err:Error)
				{
					//Do nothing, we don't care if there's an error
				}
			}
			_activeLoader = null;
			_waitingForServer = false;
		}
		
		public function Logout():void
		{
			if (!_initialized)
				return;
			
			Reset();
			if (Credentials._currentSession)
				Credentials._currentSession = null;
		}
		
		private function ValidateUsername(username:String) : String
		{
			var ret:String = "";
			if (username.length < 4 ||
				username.length > 15)
			{
				ret = "Username must be at least 4 characters and no more than 15 characters long";
			}
			else if (!FinalUsernamePattern.test(username))
			{
				ret = "Username must be composed only of letters, numbers, and basic punctuation ( - _ + ! @ # $ % ^ & * )";
			}
			return ret;
		}
		private function ValidatePassword(password:String) : String
		{
			var ret:String = "";
			if (password.length < 5 ||
				password.length > 15)
			{
				ret = "Password must be at least 5 characters and no more than 15 characters long";
			}
			else if (!FinalPasswordPattern.test(password))
			{
				ret = "Password must be composed only of letters and numbers, and must include at least one of each";
			}
			return ret;
		}
		private function ValidateUsernameVsPassword(username:String, password:String):String 
		{
			var ret:String = "";
			if (username == password)
				ret = "Username and password cannot be the same";
			else if (username.search(password) != -1)
				ret = "Username may not contain the password";
			
			return ret;
		}
		
		private function EncryptPassword(password:String) : String
		{
			return SHA1.hashToBase64(password);
		}
	}
}