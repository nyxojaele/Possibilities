package com.cinder.common.security 
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Jed Lang
	 */
	public class LoginEvent extends Event 
	{
		public var errorText:String;
		
		public function LoginEvent(type:String, errorText:String="", bubbles:Boolean=false, cancelable:Boolean=false) 
		{ 
			super(type, bubbles, cancelable);
			this.errorText = errorText;
		} 
		
		public override function clone():Event 
		{ 
			return new LoginEvent(type, errorText, bubbles, cancelable);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("LoginEvent", "type", "bubbles", "cancelable", "eventPhase", "errorText"); 
		}
		
	}
	
}