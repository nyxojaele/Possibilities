package states.play.actors.playgrid 
{
	import com.junkbyte.console.Cc;
	import flash.display.Graphics;
	import org.flixel.FlxG;
	import org.flixel.FlxRect;
	import org.flixel.FlxSprite;
	
	/**
	 * ...
	 * @author Jed Lang
	 */
	public class PlayGridLines extends FlxSprite 
	{
		private var _generated:Boolean;
		
		
		public function PlayGridLines() 
		{
			_generated = false;
		}
		
		
		public function generateIfNull(tileSpacing:Number, tileSize:Number, widthInTiles:Number, heightInTiles:Number, padding:FlxRect):void
		{
			if (!_generated)
				generate(tileSpacing, tileSize, widthInTiles, heightInTiles, padding);
		}
		public function forceGenerate(tileSpacing:Number, tileSize:Number, widthInTiles:Number, heightInTiles:Number, padding:FlxRect):void
		{
			generate(tileSpacing, tileSize, widthInTiles, heightInTiles, padding);
		}
		private function generate(tileSpacing:Number, tileSize:Number, widthInTiles:Number, heightInTiles:Number, padding:FlxRect):void
		{
			//This is the same calculation used in PlayGrid.calculateDimensions()
			var wAndH:Number = (widthInTiles + heightInTiles) / 2;
			var w:Number = (tileSize + tileSpacing) * wAndH;
			var h:Number = (tileSize + tileSpacing) * wAndH / 2;	//Half tile AND spacing on Y
			
			w += padding.left + padding.width;
			h += padding.top + padding.height;
			makeGraphic(Math.ceil(w), Math.ceil(h), 0x00000000);
			
			//Instead of calling drawLine repeatedly (causing lots of bitmap pixel copies), we draw it all manually and copy once
			var gfx:Graphics = FlxG.flashGfx;
			gfx.clear();
			gfx.lineStyle(1, 0xFFFFFF, 1);
			
			var halfTileAndSpacingSize:Number = (tileSize + tileSpacing) / 2;
			//These need to be after makeGraphic because they rely on the width of the newly made graphic (for now)
			var totalXOffset:Number = width / 2 + padding.left;
			var totalYOffset:Number = padding.top;
			for (var x:Number = 0; x <= widthInTiles; ++x)
			{
				var _x:Number = x * halfTileAndSpacingSize;
				gfx.moveTo(totalXOffset + _x, totalYOffset + _x / 2);
				gfx.lineTo(totalXOffset + _x - heightInTiles * halfTileAndSpacingSize, totalYOffset + (_x + heightInTiles * halfTileAndSpacingSize) / 2);
			}
			for (var y:Number = 0; y <= heightInTiles; ++y)
			{
				var _y:Number = y * halfTileAndSpacingSize;
				gfx.moveTo(totalXOffset - _y, totalYOffset + _y / 2);
				gfx.lineTo(totalXOffset - _y + widthInTiles * halfTileAndSpacingSize, totalYOffset + (_y + widthInTiles * halfTileAndSpacingSize) / 2);
			}
			
			pixels.draw(FlxG.flashGfxSprite);
			dirty = true;
		}
	}

}