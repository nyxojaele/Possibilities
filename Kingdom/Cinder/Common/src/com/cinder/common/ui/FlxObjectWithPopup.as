package com.cinder.common.ui 
{
	import com.junkbyte.console.Cc;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import org.flixel.FlxBasic;
	import org.flixel.FlxButton;
	import org.flixel.FlxG;
	import org.flixel.FlxGroup;
	import org.flixel.FlxObject;
	import org.flixel.FlxPoint;
	
	/**
	 * ...
	 * @author Jed Lang
	 */
	public class FlxObjectWithPopup extends FlxGroup
	{
		public var content:FlxObject;
		
		
		private static var popup:FlxPopup;			//Basically a singleton, ensures that only one popup is visible at a time
		private static var overrideOnOut:Boolean;	//OnOut must trigger before OnOver for the popup to display correctly (for situations where buttons are touching)
		private var _hoverDetect:FlxButton;
		private var _userData:*;					//Exists solely to be passed to the _populatePopup function
		private var _popuplatePopup:Function;
		
		
		//populatePopup should have the signature populatePopup(popup:FlxPopup, userData:*):void
		public function FlxObjectWithPopup(bgGraphic:Class, content:FlxObject, userData:*, populatePopup:Function) 
		{			
			this.content = content;
			add(content);
			
			_hoverDetect = new FlxButton(content.x, content.y);
			_hoverDetect.makeGraphic(content.width, content.height, 0x0);
			_hoverDetect.onOver = hoverDetect_OnOver;
			_hoverDetect.onOut = hoverDetect_OnOut;
			add(_hoverDetect);
			
			if (!popup)
			{
				popup = new FlxPopup(false, bgGraphic, "");
				popup.visible = false;
				super.add(popup);	//Avoid the override below
			}
			
			_userData = userData;
			_popuplatePopup = populatePopup;
		}
		
		override public function add(Object:FlxBasic):FlxBasic 
		{
			var ret:FlxBasic = super.add(Object);
			//Keep the popup on top
			if (popup)
			{
				remove(popup);
				super.add(popup);	//Since this function is overriding
			}
			return ret;
		}
		
		private function hoverDetect_OnOver():void 
		{
			if (popup.visible)
				//OnOut of previous button hasn't happened yet
				overrideOnOut = true;
			
			//By default the popup tries to show up at the mouse position
			//but we don't want it to be clipped off the edge of the stage
			var desiredPos:FlxPoint = FlxG.mouse.getScreenPosition();
			if (desiredPos.x + popup.width > FlxG.width)
				//Shift it left
				desiredPos.x = FlxG.width - popup.width;
			if (desiredPos.y + popup.height > FlxG.height)
				//Shift it up
				desiredPos.y = FlxG.height - popup.height;
			popup.position = desiredPos;
			_popuplatePopup(popup, _userData);
			
			popup.visible = true;
		}
		private function hoverDetect_OnOut():void 
		{
			if (!overrideOnOut)
				popup.visible = false;
			overrideOnOut = false;
		}
	}

}