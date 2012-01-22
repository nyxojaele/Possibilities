package managers 
{
	import com.cinder.common.config.Configuration;
	import com.cinder.common.datatypes.Queue;
	import com.cinder.common.security.Credentials;
	import com.junkbyte.console.Cc;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedSuperclassName;
	import managers.resources.Resource;
	import managers.resources.Resource_Gold;
	import managers.resources.Resource_Wood;
	import managers.resources.Resource_Food;
	import org.flixel.FlxG;
	/**
	 * ...
	 * @author Jed Lang
	 */
	public class Manager extends EventDispatcher
	{
		//Next request ID to use- this can be used to correlate a request with an instance, as it is unique
		//This also MUST start at 1, as some request-based stuff relies on a negative version of this value
		private static var _requestID:int = 1;
		public static function get requestID():int { return _requestID; }
		
		
		private var _connectTo:String;	//PHP URL to use for actions
		
		
		public function Manager(connectTo:String, requestReturnCallback:Function=null) 
		{
			_connectTo = connectTo;
			if (requestReturnCallback != null)
				addEventListener(ManagerEvent.MANAGER_REQUESTRETURN, requestReturnCallback);
		}
		
		
		//****************************************************
		//
		//                 PUBLIC REQUESTS
		//
		//****************************************************
		//This function should be called whenever you want to load data from the server, blowing away any data already in the object
		//Typically this should only be used on startup, to hydrate the object with server values
		public function loadDataFromServer():void
		{
			var request:URLVariables = makeRequest("getall");
			if (request)
				sendRequest(request);
		}
		
		
		//****************************************************
		//
		//                ABSTRACT FUNCITONS
		//
		//****************************************************
		protected function getMemberClassByTypeId(typeId:uint):Class
		{ throw new Error("Unimplemented function"); }
		protected function hydrateMemberWithServerData(member:ManagedItem, properties:Array):Boolean
		{ throw new Error("Unimplemented function"); }
		
		
		//****************************************************
		//
		//                PROTECTED REQUESTS
		//
		//****************************************************
		//This function should be called to setup a request to the server
		//The returned value should be hydrated with the appropriate data,
		//and then passed into sendRequest() to start the transaction.
		protected function makeRequest(action:String): URLVariables
		{
			Cc.log("Preparing request " + requestID + ": \"" + action + "\"...");
			if (!Credentials.currentSession)
			{
				Cc.error("No Credentials Session found");
				Credentials.disconnected = true;
				if (!Configuration.instance.DebugMode)
					FlxG.switchState(new MenuState);
				return null;
			}
			var sessionID:Number = Credentials.currentSession.sessionID;
			if (!sessionID)
			{
				Cc.error("No Server Session found");
				return null;	//No session
			}
			
			//Setup request
			var variables:URLVariables = new URLVariables();
			variables.DBVersion = Configuration.instance.DBVersion;
			variables.sessionID = sessionID;
			variables.action = action;
			variables.requestID = _requestID;
			++_requestID;
			
			return variables;
		}
		//This function should be called to send a request, after makeRequest()
		//has first been called to create the request. The value passed in here
		//should be the newly hydrated value that was returned from makeRequest().
		protected function sendRequest(variables:URLVariables):void
		{
			try
			{
				var varSend:URLRequest = new URLRequest(_connectTo);
				varSend.method = URLRequestMethod.POST;
				varSend.data = variables;
				
				var loader:URLLoader = new URLLoader();
				loader.dataFormat = URLLoaderDataFormat.VARIABLES;
				
				loader.addEventListener(Event.COMPLETE, requestSuccess, false, 0, true);
				loader.addEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatus, false, 0, true);
				loader.addEventListener(IOErrorEvent.IO_ERROR, ioError, false, 0, true);
				loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityError, false, 0, true);
			
				Cc.log("Sending request...");
				loader.load(varSend);
			}
			catch(er:Error)
			{
				Cc.error("Unable to send request");
				cleanupEvents(loader);
				dispatchEvent(new ManagerEvent(ManagerEvent.MANAGER_SERVERERROR, er.message));
			}
		}
		
		
		//****************************************************
		//
		//             SERVER EVENT HANDLERS
		//
		//****************************************************
		private function requestSuccess(e:Event):void 
		{
			cleanupEvents(e.currentTarget);
			try
			{
				var vars:URLVariables = new URLVariables(e.currentTarget.data);
				if (vars.Success == "1")
				{
					Cc.log("Request " + vars.RequestID + " \"" + vars.Action + "\" returned succesfully: " + vars);
					if (vars.Action == "getall")
					{
						if (!parseGetallString(vars.Result))
							dispatchEvent(new ManagerEvent(ManagerEvent.MANAGER_SERVERERROR, e.currentTarget.data));
						else
							dispatchEvent(new ManagerEvent(ManagerEvent.MANAGER_SERVERLOADEND));
					}
					else
						dispatchEvent(new ManagerEvent(ManagerEvent.MANAGER_REQUESTRETURN, e.currentTarget.data));
				}
				else
				{
					//Server error
					Cc.error("Request returned succesfully, but server reported an error: " + vars.Error + "\n" + vars);
					dispatchEvent(new ManagerEvent(ManagerEvent.MANAGER_SERVERERROR, e.currentTarget.data));
				}
			}
			catch (error:Error)
			{
				Cc.error("Error on return of server request. Data: " + e.currentTarget.data + "\nError: " + error.message + "\nStackTrace: " + error.getStackTrace());
			}
		}
		private function httpStatus(e:HTTPStatusEvent):void 
		{
			//Status Codes as per http://www.w3.org/Protocols/rfc2616/rfc2616-sec10.html
			if ((e.status >= 300 && e.status <= 307) ||
				(e.status >= 400 && e.status <= 401) ||
				(e.status >= 403 && e.status <= 417) ||
				(e.status >= 500 && e.status <= 505))
			{
				Cc.error("Request returned HTTP status code " + e.status);
				cleanupEvents(e.currentTarget);
				dispatchEvent(new ManagerEvent(ManagerEvent.MANAGER_SERVERERROR, e.currentTarget.data));
			}
			//Don't cleanup events here because we receive 200 "success" codes here as well
		}
		private function ioError(e:IOErrorEvent):void 
		{
			Cc.error("Request IO error");
			cleanupEvents(e.currentTarget);
			dispatchEvent(new ManagerEvent(ManagerEvent.MANAGER_SERVERERROR, e.currentTarget.data));
		}
		private function securityError(e:SecurityErrorEvent):void 
		{
			Cc.error("Request security error");
			cleanupEvents(e.currentTarget);
			dispatchEvent(new ManagerEvent(ManagerEvent.MANAGER_SERVERERROR, e.currentTarget.data));
		}
		
		
		//****************************************************
		//
		//                 HELPER FUNCTIONS
		//
		//****************************************************
		private function parseGetallString(str:String):Boolean
		{
			if (!str || str == "") return true;		//No items
			var values:Array = str.split("|");
			dispatchEvent(new ManagerEvent(ManagerEvent.MANAGER_SERVERLOADSTART, values.length.toString()));
			if (values.length == 0) return true;	//No items - this shouldn't be reachable because of the above check tho
			
			var error:Boolean = false;
			for each (var value:String in values)
			{
				var properties:Array = value.split(",");
				if (properties.length < 2)
				{
					Cc.error("Parsing server string provided value with less than 2 properties: " + value);
					error = true;
					break;
				}
				if (isNaN(uint(properties[0])) ||	//ClassID
					isNaN(int(properties[1])))		//Instance ID
				{
					Cc.error("Parsing server string provided NaN value for one of the first 2 properties: " + value);
					error = true;
					break;
				}
				var cls:Class = getMemberClassByTypeId(uint(properties[0]));
				var workingValue:* = new cls(int(properties[1]));
				if (!(workingValue is ManagedItem))
				{
					Cc.error("Invalid class " + cls + " returned by Manager for typeID " + properties[0] + " when parsing server string");
					error = true;
					break;
				}
				if (!hydrateMemberWithServerData(workingValue, properties))
				{
					Cc.error("Derived error when hydrating value from server with properties: " + value);
					error = true;
					break;
				}
			}
			if (error)
			{
				dispatchEvent(new ManagerEvent(ManagerEvent.MANAGER_SERVERERROR, str));
				return false;
			}
			return true;
		}
		private function cleanupEvents(currentTarget:Object):void
		{
			var loader:URLLoader = currentTarget as URLLoader;
			if (loader)
			{
				loader.removeEventListener(Event.COMPLETE, requestSuccess);
				loader.removeEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatus);
				loader.removeEventListener(IOErrorEvent.IO_ERROR, ioError);
				loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, securityError);
			}
		}
	}
}