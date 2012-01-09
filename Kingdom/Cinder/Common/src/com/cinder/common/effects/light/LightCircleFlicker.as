package com.cinder.common.effects.light 
{
	import org.flixel.FlxSprite;
	/**
	 * ...
	 * @author Jed Lang
	 */
	public class LightCircleFlicker extends Light 
	{
		[Embed(source = "/data/gfx/effects/light_circle_flicker.png")]
		private static const ImgLight:Class;
		
		public function LightCircleFlicker(x:Number, y:Number, scale:Number, darkness:FlxSprite) 
		{
			super(x, y, scale, darkness);
			
			loadGraphic(ImgLight, true);
			addAnimation("flicker", [0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0], 15);
			play("flicker");
		}
		
	}

}