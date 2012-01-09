package idv.cjcat.stardust.threeD.away3d.initializers {
	import away3d.sprites.Sprite3D;
	import idv.cjcat.stardust.common.utils.construct;
	import idv.cjcat.stardust.threeD.initializers.Initializer3D;
	import idv.cjcat.stardust.common.particles.Particle;
	
	/**
	 * Assigns a <code>Sprite3D</code> object to the <code>target</code> properties of a particle.
	 * This information can be visualized by <code>Alternativa3DRenderer</code>.
	 *
	 * @see away3d.sprites.Sprite3D
	 * @see idv.cjcat.stardust.threeD.away3d.handlers.Away3DSprite3DHandler
	 */
	public class Away3DSprite3DClass extends Initializer3D {
		
		private var _sprite3DClass:Class;
		private var _constructorParams:Array;
		public function Away3DSprite3DClass(sprite3DClass:Class = null, constructorParams:Array = null) {
			this.sprite3DClass = sprite3DClass;
			this.constructorParams = constructorParams;
		}
		
		public function get sprite3DClass():Class { return _sprite3DClass; }
		public function set sprite3DClass(value:Class):void {
			if (!value) value = Sprite3D;
			_sprite3DClass = value;
		}
		
		public function get constructorParams():Array { return _constructorParams; }
		public function set constructorParams(value:Array):void {
			if (!value) value = [];
			_constructorParams = value;
		}
		
		override public final function initialize(particle:Particle):void {
			var s3D:Sprite3D = Sprite3D(construct(_sprite3DClass, _constructorParams));
			particle.target = s3D;
		}
		
		
		//XML
		//------------------------------------------------------------------------------------------------
		
		override public function getXMLTagName():String {
			return "Away3DSprite3DClass";
		}
		
		//------------------------------------------------------------------------------------------------
		//end of XML
	}
}