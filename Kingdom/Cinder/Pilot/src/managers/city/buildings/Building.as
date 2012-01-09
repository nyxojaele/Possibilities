package managers.city.buildings 
{
	import com.cinder.common.ui.FlxSpriteEx;
	import com.junkbyte.console.Cc;
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	import managers.ManagedItem;
	import org.flixel.FlxG;
	import org.flixel.FlxPoint;
	import org.flixel.FlxSprite;
	import managers.resources.ResourceCollection;
	import org.flixel.FlxCamera;
	
	/**
	 * ...
	 * @author Jed Lang
	 */
	public class Building extends ManagedItem
	{
		private var _name:String = "";
		public function get name():String { return _name; }
		public function get resourceCost():ResourceCollection { return ResourceCollection.empty; }
		
		private var _maxHealth:Number;
		public function get maxHealth():Number { return _maxHealth; }
		protected var _currentHealth:Number;
		public function get currentHealth():Number { return _currentHealth; }
		public function initFromServerData(health:Number):void { _currentHealth = health; }
		
		
		private var _wInTiles:Number;
		public function get wInTiles():Number { return _wInTiles; }
		private var _hInTiles:Number;
		public function get hInTiles():Number { return _hInTiles; }
		
		private var _graphics:FlxSprite
		public function get graphics():FlxSprite { return _graphics; }
		private var _hiliteBorder:Number = 0;
		private var _hiliteRect:Rectangle;
		private var _hiliteGenerated:Boolean;
		private var _hilite:BitmapData;
		
		private var _point:FlxPoint;			//Just a pre-allocated FlxPoint to be used when needed
		private var _flashPoint:Point;			//Just a pre-allocated Point to be used when needed
		
		
		public function Building(id:int, imgPath:String, hiliteImg:Class, wInTiles:Number, hInTiles:Number, name:String, maxHP:Number) 
		{
			super(id);
			
			_wInTiles = wInTiles;
			_hInTiles = hInTiles;
			
			_graphics = new FlxSpriteEx(imgPath, 0, 0);
			
			//These values are calculated based on values that get populated in the super ctor
			var modX:Number = 0;
			var modY:Number = 0;
			if (!hiliteImg)
			{
				//1 pixel border around edges
				_hiliteBorder = 1;
				_hiliteRect = new Rectangle(0, 0, _graphics.width + _hiliteBorder * 2, _graphics.height + _hiliteBorder * 2);
				_hilite = new BitmapData(_hiliteRect.width, _hiliteRect.height, true, 0x00000000);
			}
			else
			{
				_hilite = FlxG.addBitmap(hiliteImg);
				_hiliteRect = new Rectangle(0, 0, _hilite.width, _hilite.height);
				_hiliteGenerated = true;
			}
			
			//These values get used for calculating where hilite is positioned
			if (imgPath == null)
			{
				_graphics.width = _hiliteRect.width;
				_graphics.height = _hiliteRect.height;
			}
			
			//Other values
			_name = name;
			_maxHealth = maxHP;
			_currentHealth = maxHP;
			
			//Pre-allocate variables
			_point = new FlxPoint();
			_flashPoint = new Point();
		}
		
		
		public function drawHilite():void
		{
			//This is expensive- only do it if we absolutely have to!
			//TODO: Can this be made static per-building somehow?
			if (!_hiliteGenerated)
			{
				//We only get here if the hilite graphic hasn't been manually loaded, which means we have a border
				_hilite.lock();
				var rect:Rectangle = new Rectangle();
				for (var _y:int = 0; _y < _hilite.height; ++_y)
				{
					for (var _x:int = 0; _x < _hilite.width; ++_x)
					{
						var xBorder:Boolean = _x < _hiliteBorder || _x >= (_graphics.pixels.width + _hiliteBorder);
						var yBorder:Boolean = _y < _hiliteBorder || _y >= (_graphics.pixels.width + _hiliteBorder);
						var pixel:uint = (xBorder || yBorder) ? 0 : _graphics.pixels.getPixel32(_x - _hiliteBorder, _y - _hiliteBorder);
						if (pixel == 0)	//Only sample transparent pixels
						{
							//This rect is used for sampling from pixels, so needs to be constrained within its boundaries
							rect.left = Math.max(_x - 1 - _hiliteBorder, 0);
							rect.top = Math.max(_y - 1 - _hiliteBorder, 0);
							rect.right = Math.min(_x + 2 - _hiliteBorder, _graphics.pixels.width);	//+2 because it's exclusive
							rect.bottom = Math.min(_y + 2 - _hiliteBorder, _graphics.pixels.height);
						
							var px:ByteArray = _graphics.pixels.getPixels(rect);
							px.position = 0;	//Not sure why this isn't 0 by default, but whatever
							
							var found:Boolean = false;
							for (var _i:int = 0; _i < px.length / 4; ++_i)
							{
								var b:int = px.readUnsignedInt();
								if (b != 0)
								{
									found = true;
									break;
								}
							}
							
							if (found)
								_hilite.setPixel32(_x, _y, 0xAAFF1111);
						}
					}
				}
				_hilite.unlock();
				
				_hiliteGenerated = true;
			}
			
			//Draw
			var cameras:Array = FlxG.cameras;
			var camera:FlxCamera;
			var i:uint = 0;
			var l:uint = cameras.length;
			while(i < l)
			{
				camera = cameras[i++];
				if(!_graphics.onScreen(camera))
					continue;
				_point.x = _graphics.x - _hiliteBorder - int(camera.scroll.x*_graphics.scrollFactor.x) - _graphics.offset.x;
				_point.y = _graphics.y - _hiliteBorder - int(camera.scroll.y*_graphics.scrollFactor.y) - _graphics.offset.y;
				_point.x += (_point.x > 0)?0.0000001:-0.0000001;
				_point.y += (_point.y > 0)?0.0000001: -0.0000001;
				
				//Always simple render
				_flashPoint.x = _point.x;
				_flashPoint.y = _point.y;
				camera.buffer.copyPixels(_hilite, _hiliteRect, _flashPoint, null, null, true);
			}
		}
		
		public function destroy():void
		{
			_graphics.destroy();
		}
	}
}