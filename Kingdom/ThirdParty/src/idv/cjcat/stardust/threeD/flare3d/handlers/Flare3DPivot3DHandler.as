package idv.cjcat.stardust.threeD.flare3d.handlers {
	import flare.core.Pivot3D;
	import idv.cjcat.stardust.common.handlers.ParticleHandler;
	import idv.cjcat.stardust.common.particles.Particle;
	import idv.cjcat.stardust.threeD.particles.Particle3D;
	
	/**
	 * This handler adds <code>Pivot3D</code> particles to a <code>Pivot3D</code> container, 
	 * removes dead particles from the container, 
	 * and updates the <code>Pivot3D</code> objects' x, y, z, rotationX, rotationY, rotationZ, scaleX, scaleY, and scaleZ properties.
	 */
	public class Flare3DPivot3DHandler extends ParticleHandler {
		
		private var container:Pivot3D;
		
		public function Flare3DPivot3DHandler(container:Pivot3D = null) {
			this.container = container;
		}
		
		private var pivot3D:Pivot3D; 
		
		override public function particleAdded(particle:Particle):void {
			pivot3D = Pivot3D(particle.target);
			container.addChild(pivot3D);
			particle.dictionary[Flare3DPivot3DHandler] = container;
		}
		
		override public function particleRemoved(particle:Particle):void {
			pivot3D = Pivot3D(particle.target);
			container = Pivot3D(particle.dictionary[Flare3DPivot3DHandler]);
			container.removeChild(pivot3D);
		}
		
		private var p3D:Particle3D;
		
		override public function readParticle(particle:Particle):void {
			p3D = Particle3D(particle);
			
			pivot3D = Pivot3D(particle.target);
				
			pivot3D.x = p3D.x;
			pivot3D.y = p3D.y;
			pivot3D.z = p3D.z;
			pivot3D.setRotation(p3D.rotationX, p3D.rotationY, p3D.rotationZ);
			pivot3D.scaleX = pivot3D.scaleY = pivot3D.scaleZ = particle.scale;
		}
		
		
		//XML
		//------------------------------------------------------------------------------------------------
		
		override public function getXMLTagName():String {
			return "Flare3DPivot3DHandler";
		}
		
		//------------------------------------------------------------------------------------------------$
		//end of XML
	}
}