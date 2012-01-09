package org.flixel 
{
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.ui.Keyboard;
	/**
	 * ...
	 * @author Jed Lang
	 */
	public class FlxInputText extends FlxText 
	{
		static public const NO_RESTRICT:uint		= 0;
		static public const ONLY_ALPHA:uint			= 1;
		static public const ONLY_NUMERIC:uint		= 2;
		static public const ONLY_ALPHANUMERIC:uint	= 3;
		
		public function set builtinRestriction(restriction:uint):void
		{
			switch (restriction)
			{
				case NO_RESTRICT:
					{
						_textField.restrict = null;
						break;
					}
				case ONLY_ALPHA:
					{
						_textField.restrict = "a-zA-Z";
						break;
					}
				case ONLY_NUMERIC:
					{
						_textField.restrict = "0-9";
						break;
					}
				case ONLY_ALPHANUMERIC:
					{
						_textField.restrict = "a-zA-Z0-9";
						break;
					}
			}
		}
		public function set customRestriction(restriction:String):void
		{
			_textField.restrict = restriction;
		}
		
		//@desc Another FlxInputText to focus on when the <Tab> key is pressed while this one is focused
		public var nextTabFocus:FlxInputText;
		
		//@desc A FlxButton to simulate a click on when the <Enter> key is pressed
		public var enterButton:FlxButton;
		
		private var _initialized:Boolean;	//This is currently only used for the mouse handler
		
		public function FlxInputText(x:Number, y:Number, width:uint, text:String, color:uint=0x000000, font:String=null, size:uint=8, justification:String=null, angle:Number=0) 
		{
			super(x, y, width, text);
			
			_optimizeDisplay = false;
			
			_textField.selectable = true;
			_textField.type = TextFieldType.INPUT;
			_textField.multiline = false;
			_textField.wordWrap = false;
			_textField.background = true;
			_textField.backgroundColor = (~color) & 0xFFFFFF;
			_textField.textColor = color;
			_textField.border = true;
			_textField.borderColor = color;
			_textField.visible = false;
			_textField.width = width - 4;
			_textField.height = size + 4;
			this.angle = angle;
			this.size = size;
			
			_textField.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			
			_regen = true;	//This forces the pixels to be regenerated; Specifically for when using non-standard text sizes.
		}
		override public function destroy():void 
		{
			_textField.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			if (FlxG.stage != null)
				FlxG.stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			super.destroy();
		}
		
		private function onKeyDown(e:KeyboardEvent):void 
		{
			if (e.keyCode == Keyboard.TAB)
			{
				if (nextTabFocus != null)
					nextTabFocus.focus();
			}
			else if (e.keyCode == Keyboard.ENTER)
			{
				if (enterButton != null)
					enterButton.Click();
			}
		}
		
		/**
		 * Since inputText uses its own mouse/keyboard handler for thread reasons,
		 * we run a little pre-check here to make sure that we only add
		 * the mouse handler when it is actually safe to do so.
		 */
		public override function preUpdate():void
		{
			super.preUpdate();
			
			if (!_initialized)
			{
				if (FlxG.stage != null)
				{
					FlxG.stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
					_initialized = true;
				}
			}
		}
		
		private function onMouseUp(e:MouseEvent):void 
		{
			if (FlxG.mouse.visible)
			{
				if (cameras == null)
					cameras = FlxG.cameras;
				var camera:FlxCamera;
				var i:uint = 0;
				var l:uint = cameras.length;
				while (i < l)
				{
					camera = cameras[i++] as FlxCamera;
					FlxG.mouse.getWorldPosition(camera, _point);
					if (overlapsPoint(_point, true, camera))
					{
						focus();
						//After focusing, we want to set the caret to the position under the mouse cursor
						var localX:Number = FlxG.mouse.screenX - x;
						var localY:Number = FlxG.mouse.screenY - y;
						var idx:Number = (localX > _textField.textWidth ? _textField.text.length : _textField.getCharIndexAtPoint(localX, localY));
						_textField.setSelection(idx, idx);
					}
				}
			}
		}
		
		public override function draw(): void
		{
			calcFrame();	//The caret won't flash without this
			super.draw();
		}
		
		public function set backgroundColor(color:uint):void { _textField.backgroundColor = color; }
		public function get backgroundColor():uint { return _textField.backgroundColor; }
		public function set borderColor(color:uint):void { _textField.borderColor = color; }
		public function get borderColor():uint { return _textField.borderColor; }
		public function set backgroundVisible(enabled:Boolean):void { _textField.background = enabled; }
		public function get backgroundVisible():Boolean { return _textField.background; }
		public function set borderVisible(enabled:Boolean):void { _textField.border = enabled; }
		public function get borderVisible():Boolean { return _textField.border; }
		public function set displayAsPassword(display:Boolean):void { _textField.displayAsPassword = display; }
		public function get displayAsPassword():Boolean { return _textField.displayAsPassword; }
		
		//@desc Set the maximum length for the field (e.g. "3" for Arcade hi-score initials)
		//@param Length The maximum length. 0 means unlimited.
		public function setMaxLength(length:uint):void
		{
			_textField.maxChars = length;
		}
		
		public function focus():void
		{
			FlxG.stage.focus = _textField;
		}
	}

}