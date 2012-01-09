package idv.cjcat.stardust.threeD.away3d.handlers {
	import away3d.containers.ObjectContainer3D;
	import away3d.core.base.Object3D;
	import away3d.sprites.Sprite3D;
	import idv.cjcat.stardust.common.handlers.ParticleHandler;
	import idv.cjcat.stardust.common.particles.Particle;
	import idv.cjcat.stardust.threeD.particles.Particle3D;
	
	/**
	 * This handler adds <code>Sprite3D</code> particles to a <code>ObjectContainer3D</code> container,
	 * removes dead particles from the container,
	 * and updates the <code>Sprite3D</code> objects' x, y, z, and scaling properties.
	 */
	public class Away3DSprite3DHandler extends ParticleHandler {
		
		public function Away3DSprite3DHandler(container:ObjectContainer3D = null) {
			this.container = container;
		}
		
		private var sp3D:Sprite3D;
		private var container:ObjectContainer3D;
		
		override public function particleAdded(particle:Particle):void {
			sp3D = Sprite3D(particle.target);
			container.addSprite(sp3D);
			particle.dictionary[Away3DSprite3DHandler] = container;
		}
		
		override public function particleRemoved(particle:Particle):void {
			sp3D = Sprite3D(particle.target);
			container.removeSprite(sp3D);
		}
		
		private var p3D:Particle3D;
		
		override public function readParticle(particle:Particle):void {
			p3D = Particle3D(particle);
			sp3D = Sprite3D(particle.target);
			sp3D.x = p3D.x;
			sp3D.y = p3D.y;
			sp3D.z = p3D.z;
			sp3D.scaling = particle.scale;
		}
	}
}