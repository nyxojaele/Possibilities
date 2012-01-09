package idv.cjcat.stardust.threeD.flare3d.initializers {
	import flare.core.Pivot3D;
	import idv.cjcat.stardust.common.particles.Particle;
	import idv.cjcat.stardust.common.utils.construct;
	import idv.cjcat.stardust.threeD.initializers.Initializer3D;
	
	/**
	 * Assigns a <code>Pivot3D</code> object to the <code>target</code> properties of a particle. 
	 * This information can be visualized by <code>Flare3DPivot3DRenderer</code>.
	 * 
	 * @see idv.cjcat.stardust.threeD.flare3d.renderers.Flare3DPivot3DRenderer
	 */
	public class Flare3DPivot3DClass extends Initializer3D {
		
		private var _pivot3DClass:Class;
		private var _constructorParams:Array;
		public function Flare3DPivot3DClass(pivot3DClass:Class = null, constructorParams:Array = null) {
			this.pivot3DClass = pivot3DClass;
			this.constructorParams = constructorParams;
		}
		
		public function get pivot3DClass():Class { return _pivot3DClass; }
		public function set pivot3DClass(value:Class):void {
			if (!value) value = Pivot3D;
			_pivot3DClass = value;
		}
		
		public function get constructorParams():Array { return _constructorParams; }
		public function set constructorParams(value:Array):void {
			if (!value) value = [];
			_constructorParams = value;
		}
		
		override public final function initialize(particle:Particle):void {
			var pivot3D:Pivot3D = Pivot3D(construct(_pivot3DClass, _constructorParams));
			particle.target = pivot3D;
		}
		
		
		//XML
		//------------------------------------------------------------------------------------------------
		
		override public function getXMLTagName():String {
			return "Flare3DPivot3DClass";
		}
		
		//------------------------------------------------------------------------------------------------
		//end of XML
	}
}