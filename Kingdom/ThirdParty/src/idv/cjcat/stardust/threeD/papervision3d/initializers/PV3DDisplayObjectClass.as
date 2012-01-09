package idv.cjcat.stardust.threeD.papervision3d.initializers {
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.errors.IllegalOperationError;
	import idv.cjcat.stardust.common.particles.Particle;
	import idv.cjcat.stardust.common.utils.construct;
	import idv.cjcat.stardust.threeD.initializers.Initializer3D;
	import org.papervision3d.core.geom.renderables.Particle;
	import org.papervision3d.materials.special.MovieParticleMaterial;
	
	/**
	 * Assigns a <code>Particle</code> object to the <code>target</code> properties of a particle, 
	 * and uses a display object along with a <code>MovieParticleMaterial</code> object to create particle material.
	 * This information can be visualized by <code>PV3DDisplayObjectRenderer</code>.
	 * 
	 * @see org.papervision3d.core.geom.renderables.Particle
	 * @see idv.cjcat.stardust.threeD.papervision3d.renderers.PV3DDisplayObjectRenderer
	 */
	public class PV3DDisplayObjectClass extends Initializer3D {
		
		public var animated:Boolean;
		private var _constructorParams:Array;
		private var _displayObjectClass:Class;
		public function PV3DDisplayObjectClass(displayObjectClass:Class = null, constructorParams:Array = null, animated:Boolean = false) {
			this.animated = animated;
			this.constructorParams = constructorParams;
			this.displayObjectClass = displayObjectClass;
		}
		
		public function get displayObjectClass():Class { return _displayObjectClass; }
		public function set displayObjectClass(value:Class):void {
			if (!value) value = Shape;
			if (!(new value() is DisplayObject)) {
				throw new IllegalOperationError("The display object class must be a subclass of the DisplayObject class.");
			}
			_displayObjectClass = value;
		}
		
		public function get constructorParams():Array { return _constructorParams; }
		public function set constructorParams(value:Array):void {
			if (!value) value = [];
			_constructorParams = value;
		}
		
		override public final function initialize(particle:idv.cjcat.stardust.common.particles.Particle):void {
			var displayObj:DisplayObject = DisplayObject(construct(_displayObjectClass, _constructorParams));
			var sprite:Sprite = new Sprite();
			sprite.addChild(displayObj);
			var mat:MovieParticleMaterial = new MovieParticleMaterial(sprite, true, animated);
			particle.target = new org.papervision3d.core.geom.renderables.Particle(mat);
			particle.dictionary[PV3DDisplayObjectClass] = sprite;
		}
		
		//XML
		//------------------------------------------------------------------------------------------------
		
		override public function getXMLTagName():String {
			return "PV3DDisplayObjectClass";
		}
		
		//------------------------------------------------------------------------------------------------$
		//end of XML
	}
}