package com.cinder.common.ui
{	
	import org.flixel.FlxG;
	import org.flixel.FlxSprite;
	/**
	 * This extension of FlxSprite instead loads its graphics from an external source.
	 * 
	 * @author	Jed Lang
	 */
	public class FlxSpriteEx extends FlxSprite
	{
		[Embed(source = "../../../../data/gfx/null.png")]
		private static const NULLIMG_PNG:Class;
		
		
		public function FlxSpriteEx(imagePath:String, x:Number, y:Number)
		{
			var graphic:* = null;
			super(x, y, NULLIMG_PNG);
			if (imagePath)
			{
				graphic = FlxG.getExternalBitmap(imagePath);
				if (graphic)
				{
					_bakedRotation = 0;
					_pixels = graphic;
					_flipped = 0;
					frameWidth = width = _pixels.width;
					frameHeight = height = _pixels.height;
					resetHelpers();
				}
			}
		}
	}
}