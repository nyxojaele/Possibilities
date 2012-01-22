package com.cinder.common.ui 
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import org.flixel.FlxButton;
	import org.flixel.FlxCamera;
	import org.flixel.FlxG;
	
	/**
	 * ...
	 * @author Jed Lang
	 */
	public class FlxButtonWithEvents extends FlxButton implements IEventDispatcher
	{
		private var _eventDispatcher:EventDispatcher;
		
		
		public function FlxButtonWithEvents(x:Number=0, y:Number=0, label:String=null, onClick:Function=null) 
		{
			_eventDispatcher = new EventDispatcher(this);
			super(x, y, label, onClick);
		}
		
		
		protected override function updateButton():void 
		{
			//Figure out if the button is highlighted or pressed or what
			// (ignore checkbox behavior for now).
			if(FlxG.mouse.visible)
			{
				if(cameras == null)
					cameras = FlxG.cameras;
				var camera:FlxCamera;
				var i:uint = 0;
				var l:uint = cameras.length;
				var offAll:Boolean = true;
				while(i < l)
				{
					camera = cameras[i++] as FlxCamera;
					FlxG.mouse.getWorldPosition(camera,_point);
					if(overlapsPoint(_point,true,camera))
					{
						offAll = false;
						if(FlxG.mouse.justPressed())
						{
							status = PRESSED;
							if(onDown != null)
								onDown();
							if(soundDown != null)
								soundDown.play(true);
							dispatchEvent(new ButtonEvent(ButtonEvent.MOUSE_JUSTPRESSED));
						}
						if(status == NORMAL)
						{
							status = HIGHLIGHT;
							if(onOver != null)
								onOver();
							if(soundOver != null)
								soundOver.play(true);
							dispatchEvent(new ButtonEvent(ButtonEvent.MOUSE_JUSTOVER));
						}
					}
				}
				if(offAll)
				{
					if(status != NORMAL)
					{
						if(onOut != null)
							onOut();
						if(soundOut != null)
							soundOut.play(true);
						dispatchEvent(new ButtonEvent(ButtonEvent.MOUSE_JUSTOUT));
					}
					status = NORMAL;
				}
			}
		
			//Then if the label and/or the label offset exist,
			// position them to match the button.
			if(label != null)
			{
				label.x = x;
				label.y = y;
			}
			if(labelOffset != null)
			{
				label.x += labelOffset.x;
				label.y += labelOffset.y;
			}
			
			//Then pick the appropriate frame of animation
			if((status == HIGHLIGHT) && _onToggle)
				frame = NORMAL;
			else
				frame = status;
		}
		
		
		/* INTERFACE flash.events.IEventDispatcher */
		public function dispatchEvent(event:Event):Boolean 
		{
			return _eventDispatcher.dispatchEvent(event);
		}
		public function hasEventListener(type:String):Boolean 
		{
			return _eventDispatcher.hasEventListener(type);
		}
		public function willTrigger(type:String):Boolean 
		{
			return _eventDispatcher.willTrigger(type);
		}
		public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void 
		{
			_eventDispatcher.removeEventListener(type, listener, useCapture);
		}
		public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void 
		{
			_eventDispatcher.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}
	}
}