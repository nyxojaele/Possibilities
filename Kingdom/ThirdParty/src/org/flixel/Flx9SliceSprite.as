package org.flixel 
{
	import flash.display.BitmapData;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	/**
	 * ...
	 * @author Jed Lang
	 */
	//TODO: Animate this class similarly to FlxSprite!
	public class Flx9SliceSprite extends FlxObject 
	{
		protected var _sourceImage:BitmapData;
		protected var _grid:FlxRect;
		protected var _scaledImage:BitmapData;
		protected var _flashPoint:Point;
		protected var _flashRect:Rectangle;
		protected var _smoothing:Boolean;
		public function get smoothing():Boolean { return _smoothing; }
		public function set smoothing(value:Boolean):void
		{
			_smoothing = value;
			buildScaledImage();
		}
		protected var _color:uint = 0xFFFFFF;
		public function get color():uint { return _color; }
		public function set color(value:uint):void
		{
			_color = value;
			buildScaledImage();
		}
		protected var _alpha:Number = 1;
		public function get alpha():Number { return _alpha; }
		public function set alpha(value:Number):void
		{
			if (value > 1) value = 1;
			if (value < 0) value = 0;
			if (value == _alpha) return;
			_alpha = value;
			buildScaledImage();
		}
		protected var _ct:ColorTransform;
		
		
		public function Flx9SliceSprite(x:Number, y:Number, width:Number, height:Number, bitmapClass:Class, grid:FlxRect, smoothing:Boolean=false) 
		{
			super(x, y, width, height);
			
			_sourceImage = FlxG.addBitmap(bitmapClass);
			_grid = grid;
			_flashPoint = new Point();	//Pre-allocated Point to use
			_flashRect = new Rectangle(0, 0, width, height);
			_smoothing = smoothing;
			
			buildScaledImage();
		}
		
		
		/**
		 * Called whenever we need to rebuild the scaled bitmap that is rendered.
		 * Do this after you modify the width/height of this sprite.
		 */
		public function buildScaledImage():void
		{
			if (_scaledImage)
				_scaledImage.dispose();
			
			_scaledImage = new BitmapData(width, height, true, 0x00000000);
			
			var rows:Array = [0, _grid.top, _grid.bottom, _sourceImage.height];
			var cols:Array = [0, _grid.left, _grid.right, _sourceImage.width];
			
			var dRows:Array = [0, _grid.top, height - (_sourceImage.height - _grid.bottom), height];
			var dCols:Array = [0, _grid.left, width - (_sourceImage.width - _grid.right), width];
			
			var origin:Rectangle;
			var draw:Rectangle;
			var mat:Matrix = new Matrix();
			var ct:ColorTransform;
			
			if (_color > 0 || alpha != 1.0)
				ct = new ColorTransform(Number(_color >> 16 & 0xFF) / 255,
										Number(_color >> 8 & 0xFF) / 255,
										Number(_color & 0xFF) / 255,
										_alpha);
			else
				ct = null;
			
			for (var cx:int = 0; cx < 3; ++cx)
			{
				for (var cy:int = 0; cy < 3; ++cy)
				{
					origin = new Rectangle(cols[cx], rows[cy], cols[cx + 1] - cols[cx], rows[cy + 1] - rows[cy]);
					draw = new Rectangle(dCols[cx], dRows[cy], dCols[cx + 1] - dCols[cx], dRows[cy + 1] - dRows[cy]);
					mat.identity();
					mat.a = draw.width / origin.width;
					mat.d = draw.height / origin.height;
					mat.tx = draw.x - origin.x * mat.a;
					mat.ty = draw.y - origin.y * mat.d;
					_scaledImage.draw(_sourceImage, mat, ct, null, draw, _smoothing);
				}
			}
			_flashRect = new Rectangle(0, 0, width, height);
		}
		
		public override function draw():void
		{
			getScreenXY(_point);
			for each (var camera:FlxCamera in FlxG.cameras)
			{
				if (!onScreen(camera))
					continue;
					
				_point.x = x - int(camera.scroll.x * scrollFactor.x);
				_point.y = y - int(camera.scroll.y * scrollFactor.y);
				_point.x += (_point.x > 0) ? 0.0000001 : -0.0000001;
				_point.y += (_point.y > 0) ? 0.0000001 : -0.0000001;
				_flashPoint.x = _point.x;
				_flashPoint.y = _point.y;
				camera.buffer.copyPixels(_scaledImage, _flashRect, _flashPoint, null, null, true);
			}
		}
		
		public override function destroy():void
		{
			super.destroy();
			_scaledImage.dispose();
		}
	}

}