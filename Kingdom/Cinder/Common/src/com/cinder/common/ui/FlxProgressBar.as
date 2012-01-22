package com.cinder.common.ui 
{
	import com.junkbyte.console.Cc;
	import org.flixel.Flx9SliceSprite;
	import org.flixel.FlxGroup;
	import org.flixel.FlxRect;
	import org.flixel.FlxText;
	
	/**
	 * ...
	 * @author Jed Lang
	 */
	public class FlxProgressBar extends FlxGroup 
	{
		public var minValue:Number = 0;
		public var maxValue:Number = 100;
		public var currentValue:Number = 50;
		
		
		private var _bg:Flx9SliceSprite;
		private var _bar:Flx9SliceSprite;
		private var _text:FlxText;
		private var _width:Number;
		
		
		public function FlxProgressBar(x:Number, y:Number, width:Number=100, height:Number=20)
		{
			_width = width;
			
			_bg = new Flx9SliceSprite(x, y, width, height, Pilot.POPUPIMG_PNG, new FlxRect(4, 4, 56, 56));
			add(_bg);
			_bar = new Flx9SliceSprite(x, y, width, height, Pilot.PROGRESSBAR_BAR_PNG, new FlxRect(4, 4, 56, 56));
			add(_bar);
			_text = new FlxText(x + width / 2 - 7, y + 4, 30);
			add(_text);
		}
		
		
		override public function update():void 
		{
			super.update();
			
			Cc.info("1");
			var useMax:Number = maxValue ? maxValue : 1;
			var useMin:Number = (minValue >= 0 && minValue < useMax) ? minValue : 0;
			var useCurrent:Number = currentValue;
			if (useCurrent < useMin)
				useCurrent = useMin;
			if (useCurrent > useMax)
				useCurrent = useMax;
				
			var range:Number = useMax - useMin;
			var percent:Number = useCurrent / range;
			
			var newWidth:Number = percent * _width;
			_bar.width = newWidth ? newWidth : 1;
			_bar.buildScaledImage();	//Causes image to be rebuilt since width changed
			_text.text = ((percent * 100) as Number).toFixed(0) + "%";
			Cc.info("2");
		}
	}
}