package idv.cjcat.stardust.threeD.away3d.handlers {
	import away3d.containers.ObjectContainer3D;
	import away3d.core.base.Object3D;
	import idv.cjcat.stardust.common.handlers.ParticleHandler;
	import idv.cjcat.stardust.common.particles.Particle;
	import idv.cjcat.stardust.threeD.particles.Particle3D;
	
	/**
	 * This handler adds <code>Object3D</code> particles to a <code>ObjectContainer3D</code> container,
	 * removes dead particles from the container,
	 * and updates the <code>Object3D</code> objects' x, y, z, rotationX, rotationY, rotationZ, scaleX, scaleY, scaleZ, and alpha properties.
	 */
	public class Away3DObject3DHandler extends ParticleHandler {
		
		public function Away3DObject3DHandler(container:ObjectContainer3D = null) {
			this.container = container;
		}
		
		private var o3D:Object3D;
		private var container:ObjectContainer3D;
		
		override public function particleAdded(particle:Particle):void {
			var o3D:Object3D = Object3D(particle.target);
			container.addChild(o3D);
			particle.dictionary[Away3DObject3DHandler] = container;
		}
		
		override public function particleRemoved(particle:Particle):void {
			var o3D:Object3D = Object3D(particle.target);
			container.removeChild(o3D);
		}
		
		private var p3D:Particle3D;
		
		override public function readParticle(particle:Particle):void {
			p3D = Particle3D(particle);
			var o3D:Object3D = Object3D(particle.target);
			o3D.x = p3D.x;
			o3D.y = p3D.y;
			o3D.z = p3D.z;
			o3D.alpha = p3D.alpha;
			o3D.rotationX = p3D.rotationX;
			o3D.rotationY = p3D.rotationY;
			o3D.rotationZ = p3D.rotationZ;
			if (p3D.scale <= 0) p3D.scale = 0.0001;
			o3D.scaleX = o3D.scaleY = o3D.scaleZ = p3D.scale;
		}
	}
}