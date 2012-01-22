package com.cinder.common.ui 
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Jed Lang
	 */
	public class ButtonEvent extends Event 
	{
		public static const MOUSE_JUSTPRESSED:String = "Mouse_JustPressed";
		public static const MOUSE_JUSTOVER:String = "Mouse_JustOver";
		public static const MOUSE_JUSTOUT:String = "Mouse_JustOut";
		
		
		public function ButtonEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) 
		{ 
			super(type, bubbles, cancelable);
			
		} 
		
		public override function clone():Event 
		{ 
			return new ButtonEvent(type, bubbles, cancelable);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("ButtonEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}