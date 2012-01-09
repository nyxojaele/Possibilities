package
{
	import com.cinder.common.config.Configuration;
	import com.cinder.common.security.Credentials;
	import com.cinder.common.security.LoginEvent;
	import com.cinder.common.ui.FlxPopup;
	import com.facebook.graph.Facebook;
	import com.junkbyte.console.Cc;
	import flash.events.Event;
	import org.flixel.*;
	import states.menu.MainButton;

	public class MenuState extends FlxState
	{
		private var _loggedInAsLabel:FlxText;
		private var _disconnectedPopup:FlxPopup;
		
		private var _usernameLabel:FlxText;
		private var _usernameInputText:FlxInputText;
		private var _passwordLabel:FlxText;
		private var _passwordInputText:FlxInputText;
		
		private var _fbLoginButton:FlxButton;
		private var _loginButton:FlxButton;
		private var _newUserButton:FlxButton;
		
		private var _playButton:FlxButton;
		private var _debugPlayButton:FlxButton;
		
		
		override public function create():void
		{
			Cc.log("*****Menu State*****");
			FlxG.bgColor = 0xff313210;
			FlxG.mouse.show();
			
			//Disconnected label
			if (Credentials.disconnected)
			{
				_disconnectedPopup = new FlxPopup(true, Pilot.POPUPIMG_PNG, "You have been disconnected from the server", "Disconnected", FlxG.width / 2 - 100, FlxG.height / 2 - 75);
				add(_disconnectedPopup);
			}
			
			//Logged in as label
			_loggedInAsLabel = new FlxText(10, 5, 400, "Not logged in");
			_loggedInAsLabel.size = 16;
			add(_loggedInAsLabel);
			
			//Username label
			_usernameLabel = new FlxText(FlxG.width - 470, FlxG.height - 200, 200, "Username:");
			_usernameLabel.size = 16;
			_usernameLabel.alignment = "right";
			add(_usernameLabel);
			//Username input box
			_usernameInputText = new FlxInputText(FlxG.width - 270, FlxG.height - 200, 200, "", 0xFFFFFF, null, 16);
			_usernameInputText.setMaxLength(15);
			_usernameInputText.customRestriction = Credentials.UsernameRestrict;
			add(_usernameInputText);
			_usernameInputText.focus();
			
			//Password label
			_passwordLabel = new FlxText(FlxG.width - 470, FlxG.height - 160, 200, "Password:");
			_passwordLabel.size = 16;
			_passwordLabel.alignment = "right";
			add(_passwordLabel);			
			//Password input box
			_passwordInputText = new FlxInputText(FlxG.width - 270, FlxG.height - 160, 200, "", 0xFFFFFF, null, 16);
			_passwordInputText.setMaxLength(15);
			_passwordInputText.customRestriction = Credentials.PasswordRestrict;
			_passwordInputText.displayAsPassword = true;
			add(_passwordInputText);
			
			//Login using FB button
			_fbLoginButton = new MainButton(FlxG.width - 390, FlxG.height - 120, "Facebook Login", loginUsingFBButton_Click);
			_fbLoginButton.color = 0xFFD4D943;
			_fbLoginButton.label.color = 0xFFD8EBA2;
			add(_fbLoginButton);
			//Login button
			_loginButton = new MainButton(FlxG.width - 230, FlxG.height - 120, "Login", loginButton_Click);
			_loginButton.color = 0xFFD4D943;
			_loginButton.label.color = 0xFFD8EBA2;
			add(_loginButton);
			//New user button
			_newUserButton = new MainButton(FlxG.width - 230, FlxG.height - 80, "New User", newUserButton_Click);
			_newUserButton.color = 0xFFD4D943;
			_newUserButton.label.color = 0xFFD8EBA2;
			add(_newUserButton);
			
			//Play button
			_playButton = new MainButton(FlxG.width - 310, FlxG.height - 40, "Play", playButton_Click);
			_playButton.color = 0xFFD4D943;
			_playButton.label.color = 0xFFD8EBA2;
			_playButton.visible = false;
			add(_playButton);
			
			if (Configuration.instance.DebugMode)
			{
				//Debug play button
				_debugPlayButton = new MainButton(FlxG.width - 150, FlxG.height - 40, "Debug Play", debugPlayButton_Click);
				_debugPlayButton.color = 0xFFD4D943;
				_debugPlayButton.label.color = 0xFFD8EBA2;
				add(_debugPlayButton);
			}
			
			//Connect the controls together
			_usernameInputText.nextTabFocus = _passwordInputText;
			_usernameInputText.enterButton = _loginButton;
			_passwordInputText.nextTabFocus = _usernameInputText;
			_passwordInputText.enterButton = _loginButton;
			
			//Potentially this could connect via Facebook, so we want all of our controls setup first
			ConnectLoginEvents();
			Cc.log("Initializing");
			Credentials.getInstance().Init("159651034112609");
		}
		
		
		//******************************************************
		//
		//				   BUTTON CLICK HANDLERS
		//
		//******************************************************
		private function loginUsingFBButton_Click():void 
		{
			_playButton.visible = false;
			//TODO: Start FB login animation
			if (!Credentials.getInstance().FBLogin())
			{
				_loggedInAsLabel.text = "Connection in progress, please wait";
				//TODO: Stop FB login animation
			}
		}
		private function loginButton_Click():void 
		{
			_playButton.visible = false;
			//TODO: Start login animation
			if (!Credentials.getInstance().Login(_usernameInputText.text, _passwordInputText.text))
			{
				_loggedInAsLabel.text = "Connection in progress, please wait";
				//TODO: Stop login animation
			}
		}
		private function newUserButton_Click():void 
		{
			_playButton.visible = false;
			//TODO: Start new user animation
			if (!Credentials.getInstance().NewUser(_usernameInputText.text, _passwordInputText.text))
			{
				_loggedInAsLabel.text = "Connection in progress, please wait";
				//TODO: Stop new user animation
			}
		}
		private function playButton_Click():void 
		{
			DisconnectLoginEvents();
			FlxG.switchState(new StreamState);
		}
		private function debugPlayButton_Click():void 
		{
			DisconnectLoginEvents();
			FlxG.switchState(new PlayState);
		}
		
		
		//******************************************************
		//
		//				      LOGIN CALLBACKS
		//
		//******************************************************
		private function Login_Connect(e:LoginEvent):void 
		{
			//We don't disconnect events here because we expect more to come
			//TODO: new animation?
			Cc.log("Login connected");
			_loggedInAsLabel.text = "Connecting...";
		}
		private function Login_Success(e:LoginEvent):void 
		{
			//TODO: Stop all animations
			Cc.info("Logged in as " + Credentials.currentSession.username);
			_loggedInAsLabel.text = "Logged in as: " + Credentials.currentSession.username;
			_playButton.visible = true;
		}
		private function Login_Failure(e:LoginEvent):void 
		{
			//TODO: Stop all animations
			Cc.error("Login Failure: " + e.errorText);
			_loggedInAsLabel.text = "Not logged in";
		}
		
		
		//******************************************************
		//
		//				      EVENT HANDLING
		//
		//******************************************************
		private function ConnectLoginEvents():void
		{
			Credentials.getInstance().addEventListener(Credentials.LOGIN_CONNECT, Login_Connect);
			Credentials.getInstance().addEventListener(Credentials.LOGIN_SUCCESS, Login_Success);
			Credentials.getInstance().addEventListener(Credentials.LOGIN_FAILURE, Login_Failure);
		}
		private function DisconnectLoginEvents():void
		{
			Credentials.getInstance().removeEventListener(Credentials.LOGIN_CONNECT, Login_Connect);
			Credentials.getInstance().removeEventListener(Credentials.LOGIN_SUCCESS, Login_Success);
			Credentials.getInstance().removeEventListener(Credentials.LOGIN_FAILURE, Login_Failure);
		}
		
		
		//******************************************************
		//
		//				      OTHER METHODS
		//
		//******************************************************
		override public function update():void
		{
			super.update();	
		}
		
	}
}

