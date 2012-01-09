package com.cinder.common.ui 
{
	import flash.display.Graphics;
	import org.flixel.Flx9SliceSprite;
	import org.flixel.FlxButton;
	import org.flixel.FlxG;
	import org.flixel.FlxGroup;
	import org.flixel.FlxPoint;
	import org.flixel.FlxRect;
	import org.flixel.FlxSprite;
	import org.flixel.FlxText;
	
	/**
	 * ...
	 * @author Jed Lang
	 */
	public class FlxPopup extends FlxGroup 
	{
		public var key:uint;	//Use this to make checks against flags for whether this popup should be displayed or not (primarily for tutorials)
		public function set header(value:String):void
		{
			if (_headerText)
				_headerText.text = value;
		}
		public function set content(value:String):void
		{
			if (_contentText)
				_contentText.text = value;
		}
		public function set position(value:FlxPoint):void
		{
			setPointerPosFrom(value);
			setBgPosFrom(value);
			setHeaderPosFrom(value);
			setContentPosFrom(value);
			setFooterPosFrom(value);
			setClickerPosFrom(value);
			
			drawPointerGraphic(value);
		}
		private var _width:Number;
		public function get width():Number { return _width; }
		private var _height:Number;
		public function get height():Number { return _height; }
		
		
		private const border:Number = 5;
		
		
		private var _pointTo:FlxPoint;
		private var _pointerClr:uint;
		
		private var _pointer:FlxSprite;
		private var _bg:Flx9SliceSprite;
		private var _headerText:FlxText;
		private var _contentText:FlxText;
		private var _footerText:FlxText;
		private var _clicker:FlxButton;
		
		
		public function FlxPopup(clickToHide:Boolean, bgClass:Class, content:String, header:String="", x:Number=0, y:Number=0, width:Number=200, height:Number=150, pointToX:Number=-1, pointToY:Number=-1, pointerClr:uint=0xFFFFFF)
		{
			_pointerClr = pointerClr;
			_width = width;
			_height = height;
			
			var pos:FlxPoint = new FlxPoint(x, y);
			
			//Pointer
			_pointTo = new FlxPoint(pointToX, pointToY);
			_pointer = new FlxSprite();
			setPointerPosFrom(pos);
			drawPointerGraphic(pos);
			add(_pointer);
			
			//Background
			_bg = new Flx9SliceSprite(0, 0, width, height, bgClass, new FlxRect(4, 4, 56, 56));
			setBgPosFrom(pos);
			add(_bg);
			
			//Header
			_headerText = new FlxText(0, 0, width, header);
			setHeaderPosFrom(pos);
			_headerText.size = 14;
			add(_headerText);
			
			//Content
			_contentText = new FlxText(0, 0, width-10, content);
			setContentPosFrom(pos);
			_contentText.size = 10;
			add(_contentText);
			
			if (clickToHide)
			{
				//Footer
				_footerText = new FlxText(0, 0, width, "<click to close>");
				setFooterPosFrom(pos);
				add(_footerText);
				
				//Invisible button
				_clicker = new FlxButton(0, 0, "", popup_Click);
				setClickerPosFrom(pos);
				_clicker.makeGraphic(width, height, 0x0);
				add(_clicker);
			}
		}
		
		private function drawPointerGraphic(popupPos:FlxPoint):void
		{
			if (_pointTo.x != -1 &&
				_pointTo.y != -1)
			{
				var pX:Number = Math.min(popupPos.x, _pointTo.x);
				var pY:Number = Math.min(popupPos.y, _pointTo.y);
				var pX2:Number = Math.max(popupPos.x + _width, _pointTo.x);
				var pY2:Number = Math.max(popupPos.y + _height, _pointTo.y);
				
				_pointer.makeGraphic(pX2 - pX, pY2 - pY, 0x0);
				
				var gfx:Graphics = FlxG.flashGfx;
				gfx.clear();
				gfx.lineStyle(1, _pointerClr, 1);
				
				gfx.moveTo(_pointTo.x - pX, _pointTo.y - pY);
				gfx.lineTo(popupPos.x - pX, popupPos.y - pY);					//TL
				gfx.moveTo(_pointTo.x - pX, _pointTo.y - pY);
				gfx.lineTo(popupPos.x - pX, popupPos.y + _height - pY);			//BL
				gfx.moveTo(_pointTo.x - pX, _pointTo.y - pY);
				gfx.lineTo(popupPos.x + _width - pX, popupPos.y - pY);			//TR
				gfx.moveTo(_pointTo.x - pX, _pointTo.y - pY);
				gfx.lineTo(popupPos.x + _width - pX, popupPos.y + _height - pY);//BR
				
				_pointer.framePixels.draw(FlxG.flashGfxSprite);
				_pointer.visible = true;
			}
			else
				_pointer.visible = false;
		}
		
		private function setPointerPosFrom(value:FlxPoint):void
		{
			var pX:Number = Math.min(value.x, _pointTo.x);
			var pY:Number = Math.min(value.y, _pointTo.y);
			_pointer.x = pX;
			_pointer.y = pY;
		}
		private function setBgPosFrom(value:FlxPoint):void
		{
			_bg.x = value.x;
			_bg.y = value.y;
		}
		private function setHeaderPosFrom(value:FlxPoint):void
		{
			_headerText.x = value.x + border * 2;
			_headerText.y = value.y + border;
		}
		private function setContentPosFrom(value:FlxPoint):void
		{
			_contentText.x = value.x + border;
			_contentText.y = value.y + _height / 2 - 10;
		}
		private function setFooterPosFrom(value:FlxPoint):void
		{
			if (_footerText)
			{
				_footerText.x = value.x + _width / 2 - 35;
				_footerText.y = value.y + _height - 20;
			}
		}
		private function setClickerPosFrom(value:FlxPoint):void
		{
			if (_clicker)
			{
				_clicker.x = value.x;
				_clicker.y = value.y;
			}
		}
		
		
		private function popup_Click():void 
		{
			visible = false;
		}
	}
}