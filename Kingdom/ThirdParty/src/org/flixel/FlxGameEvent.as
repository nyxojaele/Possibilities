package org.flixel 
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Jed Lang
	 */
	public class FlxGameEvent extends Event 
	{
		public static const STATE_SWITCHFROM:String = "state_switchFrom";
		public static const STATE_SWITCHTO:String = "state_switchTo";
		
		public var params:Object;
		
		public function FlxGameEvent(type:String, params:Object=null, bubbles:Boolean=false, cancelable:Boolean=false) 
		{ 
			super(type, bubbles, cancelable);
			this.params = params;
		} 
		
		public override function clone():Event 
		{ 
			return new FlxGameEvent(type, params, bubbles, cancelable);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("FlxGameEvent", "params", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}