package com.cinder.common.effects.light 
{
	import org.flixel.FlxG;
	import org.flixel.FlxGame;
	import org.flixel.FlxGameEvent;
	import org.flixel.FlxGroup;
	import org.flixel.FlxSprite;
	import org.flixel.FlxState;
	
	/**
	 * This class is a singleton that can affect any state.
	 * Each state is responsible for resetting this class to
	 * it's original settings when the state is done, or
	 * undesired effects can occur.
	 * @author Jed Lang
	 */
	public class Darkness extends FlxGroup
	{
		//Singleton
		private static var _instance:Darkness;
		public static function Init(game:FlxGame): Darkness
		{
			if (_instance != null)
				throw "Darkness cannot be initialized again until it has been deinitialized";
			_instance = new Darkness(game);
			return _instance;
		}
		public static function Deinit(): void
		{
			_instance = null;
		}
		public static function get Instance(): Darkness
		{
			if (_instance == null)
				throw "Darkness must be initialized before use!";
			return _instance;
		}
		
		
		//Light type constants
		public static var LIGHT_CIRCLE:uint = 0;
		public static var LIGHT_CIRCLE_FLICKER:uint = 1;
		
		
		public var darknessColor:uint = 0x99000000;
		private var _isStatic:Boolean = false;
		public function get isStatic():Boolean { return _isStatic; }
		public function set isStatic(value:Boolean):void
		{
			_isStatic = value;
			resetAndDrawLights();
		}
		
		private var _dirty:Boolean = true;
		private var _darkness:FlxSprite;
		private var _enabled:Boolean = false;
		
		public function Darkness(game:FlxGame) 
		{
			if (_instance != null)
				throw "Darkness can only be instantiated once; It is a Singleton";
			
			//Event handling
			game.addEventListener(FlxGameEvent.STATE_SWITCHFROM, FlxGameStateSwitchedFromHandler, false, 0, true);
			game.addEventListener(FlxGameEvent.STATE_SWITCHTO, FlxGameStateSwitchedToHandler, false, 0, true);
			
			_darkness = new FlxSprite(0, 0);
			_darkness.makeGraphic(FlxG.width, FlxG.height, darknessColor);
			_darkness.scrollFactor.x = _darkness.scrollFactor.y = 0;
			_darkness.blend = "multiply";
		}
		
		//TODO: Reuse instantiated Lights (Like Stardust recycles particles!)
		public function addLight(type:uint, x:Number, y:Number, scale:Number=1): Light
		{
			var light:Light;
			switch (type)
			{
				case LIGHT_CIRCLE:
					{
						light = new LightCircle(x, y, scale, _darkness);
						break;
					}
				case LIGHT_CIRCLE_FLICKER:
					{
						light = new LightCircleFlicker(x, y, scale, _darkness);
						break;
					}
			}
			add(light);
			if (isStatic)
				light.draw();
			else
				_dirty = true;
			return light;
		}
		public function removeLight(light:Light):void
		{
			light.destroy();
			remove(light);
			if (isStatic)
				resetAndDrawLights();
			else
				_dirty = true;
		}
		public function removeAllLights():void
		{
			callAll("destroy");
			clear();
			if (isStatic)
				resetAndDrawLights();
			else
				_dirty = true;
		}
		
		private function FlxGameStateSwitchedFromHandler(e:FlxGameEvent):void 
		{
			var oldState:FlxState = e.params as FlxState;
			oldState.remove(this);
		}
		private function FlxGameStateSwitchedToHandler(e:FlxGameEvent):void 
		{
			var newState:FlxState = e.params as FlxState;
			newState.add(this);
		}
		
		public function enable():void
		{
			_enabled = true;
		}
		public function disable():void
		{
			_enabled = false;
		}
		public function isEnabled():Boolean
		{
			return _enabled;
		}
		
		override public function update():void
		{
			if (!_enabled)
				return;
				
			super.update();
		}
		override public function draw():void 
		{
			if (!_enabled)
				return;
			
			if (!isStatic && _dirty)
				resetAndDrawLights();
			_darkness.draw();	//Manually draw darkness last
		}
		private function resetAndDrawLights():void
		{
			_darkness.fill(darknessColor);
			super.draw();	//Draw lights
		}
		//Forces redrawing of lights
		public function markAsDirty():void
		{
			_dirty = true;
		}
	}

}