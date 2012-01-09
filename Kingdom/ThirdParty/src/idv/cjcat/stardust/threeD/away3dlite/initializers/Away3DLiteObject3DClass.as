package idv.cjcat.stardust.threeD.away3dlite.initializers {
	import away3dlite.core.base.Object3D;
	import idv.cjcat.stardust.common.utils.construct;
	import idv.cjcat.stardust.threeD.initializers.Initializer3D;
	import idv.cjcat.stardust.common.particles.Particle;
	
	/**
	 * Assigns a <code>Object3D</code> object to the <code>target</code> properties of a particle.
	 * This information can be visualized by <code>Away3DLiteObject3DHandler</code>.
	 *
	 * @see away3dlite.core.base.Object3D
	 * @see idv.cjcat.stardust.threeD.away3dlite.handlers.Away3DLiteObject3DHandler
	 */
	public class Away3DLiteObject3DClass extends Initializer3D {
		
		private var _object3DClass:Class;
		private var _constructorParams:Array;
		public function Away3DLiteObject3DClass(object3DClass:Class = null, constructorParams:Array = null) {
			this.object3DClass = object3DClass;
			this.constructorParams = constructorParams;
		}
		
		public function get object3DClass():Class { return _object3DClass; }
		public function set object3DClass(value:Class):void {
			if (!value) value = Object3D;
			_object3DClass = value;
		}
		
		public function get constructorParams():Array { return _constructorParams; }
		public function set constructorParams(value:Array):void {
			if (!value) value = [];
			_constructorParams = value;
		}
		
		override public final function initialize(particle:Particle):void {
			var o3D:Object3D = Object3D(construct(_object3DClass, _constructorParams));
			particle.target = o3D;
		}
		
		
		//XML
		//------------------------------------------------------------------------------------------------
		
		override public function getXMLTagName():String {
			return "Away3DLiteObject3DClass";
		}
		
		//------------------------------------------------------------------------------------------------
		//end of XML
	}
}