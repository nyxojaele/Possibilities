package idv.cjcat.stardust.threeD.nd3d.initializers {
	import de.nulldesign.nd3d.objects.Object3D;
	import idv.cjcat.stardust.common.particles.Particle;
	import idv.cjcat.stardust.common.utils.construct;
	import idv.cjcat.stardust.threeD.initializers.Initializer3D;
	
	/**
	 * Assigns a <code>Object3D</code> object to the <code>target</code> properties of a particle. 
	 * This information can be visualized by <code>ND3DObject3DRenderer</code>
	 * 
	 * @see de.nulldesign.nd3d.objects.Object3D
	 * @see idv.cjcat.stardust.threeD.nd3d.renderers.ND3DObject3DRenderer
	 */
	public class ND3DObject3DClass extends Initializer3D {
		
		private var _object3DClass:Class;
		private var _constructorParams:Array;
		public function ND3DObject3DClass(object3DClass:Class = null, constructorParams:Array = null) {
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
			var obj3D:Object3D = construct(_object3DClass, _constructorParams) as Object3D;
			particle.target = obj3D;
		}
		
		
		//XML
		//------------------------------------------------------------------------------------------------
		
		override public function getXMLTagName():String {
			return "ND3DObject3DClass";
		}
		
		//------------------------------------------------------------------------------------------------
		//end of XML
	}
}