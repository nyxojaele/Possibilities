package com.cinder.common.security 
{
	import com.facebook.graph.data.FacebookAuthResponse;
	import com.facebook.graph.Facebook;
	import com.junkbyte.console.Cc;
	/**
	 * ...
	 * @author Jed Lang
	 */
	public class Session 
	{
		private var _sessionID:Number;
		public function get sessionID():Number { return _sessionID; }
		public var _username:String;
		public function get username():String { return _username; }
		
		//Facebook stuff
		private var _fbAuthResponse:FacebookAuthResponse;
		private var _fbUser:Object;
		//TODO: Gracefully handle if the access_token has become invalid (via log out, changed password, or deauthed app)
		
		
		public function Session(id:Number, username:String) 
		{
			Cc.info("Created session " + id + " under username " + username);
			_sessionID = id;
			_username = username;
		}
		
		
		public function setFacebookMe(facebookMe:Object):void
		{
			_fbUser = facebookMe;
			if (_fbUser)
			{
				_fbAuthResponse = Facebook.getAuthResponse();
				_username = _fbUser.name;
			}
		}
	}

}