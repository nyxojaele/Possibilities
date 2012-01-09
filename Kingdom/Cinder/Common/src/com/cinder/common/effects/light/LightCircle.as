package com.cinder.common.effects.light 
{
	import org.flixel.FlxPoint;
	import org.flixel.FlxSprite;
	/**
	 * ...
	 * @author Jed Lang
	 */
	public class LightCircle extends Light 
	{
		[Embed(source = "/data/gfx/effects/light_circle.png")]
		private static const ImgLight:Class;
		
		public function LightCircle(x:Number, y:Number, scale:Number, darkness:FlxSprite) 
		{
			super(x, y, scale, darkness);
			
			loadGraphic(ImgLight);
		}
		
	}

}