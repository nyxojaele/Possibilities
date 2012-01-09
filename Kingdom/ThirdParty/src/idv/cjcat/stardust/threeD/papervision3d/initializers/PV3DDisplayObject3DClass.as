package idv.cjcat.stardust.threeD.papervision3d.initializers {
	import idv.cjcat.stardust.common.particles.Particle;
	import idv.cjcat.stardust.common.utils.construct;
	import idv.cjcat.stardust.threeD.initializers.Initializer3D;
	import org.papervision3d.objects.DisplayObject3D;
	
	/**
	 * Assigns a <code>DisplayObject</code> object to the <code>target</code> properties of a particle. 
	 * This information can be visualized by <code>PV3DDisplayObject3DRenderer</code>.
	 * 
	 * @see org.papervision3d.objects.DisplayObject3D
	 * @see idv.cjcat.stardust.threeD.papervision3d.renderers.PV3DDisplayObject3DRenderer
	 */
	public class PV3DDisplayObject3DClass extends Initializer3D {
		
		private var _displayObject3DClass:Class;
		private var _constructorParams:Array;
		public function PV3DDisplayObject3DClass(displayObject3DClass:Class = null, constructorParams:Array = null) {
			this.displayObject3DClass = displayObject3DClass;
			this.constructorParams = constructorParams;
		}
		
		public function get displayObject3DClass():Class { return _displayObject3DClass; }
		public function set displayObject3DClass(value:Class):void {
			if (!value) value = DisplayObject3D;
			_displayObject3DClass = value;
		}
		
		public function get constructorParams():Array { return _constructorParams; }
		public function set constructorParams(value:Array):void {
			if (!value) value = [];
			_constructorParams = value;
		}
		
		override public final function initialize(particle:Particle):void {
			var do3D:DisplayObject3D = DisplayObject3D(construct(_displayObject3DClass, _constructorParams));
			particle.target = do3D;
		}
		
		
		//XML
		//------------------------------------------------------------------------------------------------
		
		override public function getXMLTagName():String {
			return "PV3DDisplayObject3DClass";
		}
		
		//------------------------------------------------------------------------------------------------
		//end of XML
	}
}