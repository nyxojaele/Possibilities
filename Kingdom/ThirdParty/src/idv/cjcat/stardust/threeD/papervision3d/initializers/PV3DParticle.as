package idv.cjcat.stardust.threeD.papervision3d.initializers {
	import idv.cjcat.stardust.common.particles.Particle;
	import idv.cjcat.stardust.common.utils.construct;
	import idv.cjcat.stardust.threeD.initializers.Initializer3D;
	import org.papervision3d.core.geom.renderables.Particle;
	
	/**
	 * Assigns a <code>Particle</code> object to the <code>target</code> properties of a particle. 
	 * This information can be visualized by <code>PV3DParticleRenderer</code>.
	 * 
	 * @see org.papervision3d.core.geom.renderables.Particle
	 * @see idv.cjcat.stardust.threeD.papervision3d.renderers.PV3DParticleRenderer
	 */
	public class PV3DParticle extends Initializer3D {
		
		private var _constructorParams:Array;
		public function PV3DParticle(constructorParams:Array = null) {
			this.constructorParams = constructorParams;
		}
		
		public function get constructorParams():Array { return _constructorParams; }
		public function set constructorParams(value:Array):void {
			if (!value) value = [];
			_constructorParams = value;
		}
		
		override public final function initialize(particle:idv.cjcat.stardust.common.particles.Particle):void {
			particle.target = 
				construct(org.papervision3d.core.geom.renderables.Particle, _constructorParams);
		}
	}
}