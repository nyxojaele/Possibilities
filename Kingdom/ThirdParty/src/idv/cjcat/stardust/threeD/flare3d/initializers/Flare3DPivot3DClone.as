package idv.cjcat.stardust.threeD.flare3d.initializers {
	import flare.core.Pivot3D;
	import idv.cjcat.stardust.common.particles.Particle;
	import idv.cjcat.stardust.threeD.initializers.Initializer3D;
	
	/**
	 * Assigns a cloned <code>Pivot3D</code> object to the <code>target</code> properties of a particle. 
	 * This information can be visualized by <code>Flare3DPivot3DRenderer</code>.
	 * 
	 * @see idv.cjcat.stardust.threeD.flare3d.renderers.Flare3DPivot3DRenderer
	 */
	public class Flare3DPivot3DClone extends Initializer3D {
		
		private var _cloneTarget:Pivot3D;
		public function Flare3DPivot3DClone(cloneTarget:Pivot3D = null) {
			this.cloneTarget = cloneTarget;
		}
		
		public function get cloneTarget():Pivot3D { return _cloneTarget; }
		public function set cloneTarget(value:Pivot3D):void {
			if (!value) value = new Pivot3D();
			_cloneTarget = value;
		}
		
		override public final function initialize(particle:Particle):void {
			particle.target = _cloneTarget.clone();
		}
		
		
		//XML
		//------------------------------------------------------------------------------------------------
		
		override public function getXMLTagName():String {
			return "Flare3DPivot3DClone";
		}
		
		//------------------------------------------------------------------------------------------------
		//end of XML
	}
}