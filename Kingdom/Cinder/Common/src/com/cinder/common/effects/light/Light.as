package com.cinder.common.effects.light 
{
	import org.flixel.FlxPoint;
	import org.flixel.FlxSprite;
	
	/**
	 * ...
	 * @author Jed Lang
	 */
	public class Light extends FlxSprite 
	{
		private var _darkness:FlxSprite;
		
		public override function set x(value:Number):void
		{
			super.x = value;
			Darkness.Instance.markAsDirty();
		}
		public override function set y(value:Number):void
		{
			super.y = value;
			Darkness.Instance.markAsDirty();
		}
		
		public function Light(x:Number, y:Number, scale:Number, darkness:FlxSprite):void
		{
			super(x, y);
			
			_darkness = darkness;
			blend = "screen";
			this.scale = new FlxPoint(scale, scale);
		}
		
		public override function draw(): void
		{
			if (Darkness.Instance.isEnabled())
			{
				var screenXY:FlxPoint = getScreenXY();
				
				_darkness.stamp(this,
								screenXY.x - width / 2,
								screenXY.y - height / 2);
			}
		}
	}

}