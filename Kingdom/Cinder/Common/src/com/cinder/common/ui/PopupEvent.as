package com.cinder.common.ui 
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Jed Lang
	 */
	public class PopupEvent extends Event 
	{
		//Event consts
		public static const POPUP_CLICK:String = "Popup_Click";
		
		
		public var popup:FlxPopup;
		
		
		public function PopupEvent(type:String, popup:FlxPopup, bubbles:Boolean=false, cancelable:Boolean=false) 
		{ 
			super(type, bubbles, cancelable);
			this.popup = popup;
		} 
		
		public override function clone():Event 
		{ 
			return new PopupEvent(type, popup, bubbles, cancelable);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("PopupEvent", "popup", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}