package idv.cjcat.stardust.threeD.alternativa3d.handlers {
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.core.Object3DContainer;
	import idv.cjcat.stardust.common.handlers.ParticleHandler;
	import idv.cjcat.stardust.common.particles.Particle;
	import idv.cjcat.stardust.threeD.particles.Particle3D;
	
	/**
	 * This handler adds <code>Object3D</code> particles to a <code>Object3DContainer</code> container,
	 * removes dead particles from the container,
	 * and updates the <code>Object3D</code> objects' x, y, z, rotationX, rotationY, rotationZ, scaleX, scaleY, scaleZ, and alpha properties.
	 */
	public class Alternativa3DObject3DHandler extends ParticleHandler {
		
		public function Alternativa3DObject3DHandler(container:Object3DContainer = null) {
			this.container = container;
		}
		
		private var o3D:Object3D;
		private var container:Object3DContainer;
		
		override public function particleAdded(particle:Particle):void {
			o3D = Object3D(particle.target);
			container.addChild(o3D);
			particle.dictionary[Alternativa3DObject3DHandler] = container;
		}
		
		override public function particleRemoved(particle:Particle):void {
			o3D = Object3D(particle.target);
			container = Object3DContainer(particle.dictionary[Alternativa3DObject3DHandler]);
			container.removeChild(o3D);
		}
		
		private var p3D:Particle3D;
		
		override public function readParticle(particle:Particle):void {
			p3D = Particle3D(particle);
			o3D = Object3D(particle.target);
			o3D.x = p3D.x;
			o3D.y = p3D.y;
			o3D.z = p3D.z;
			o3D.rotationX = p3D.rotationX * Math.PI / 180;
			o3D.rotationY = p3D.rotationY * Math.PI / 180;
			o3D.rotationZ = p3D.rotationZ * Math.PI / 180;
			o3D.scaleX = o3D.scaleY = o3D.scaleZ = particle.scale;
			o3D.alpha = p3D.alpha;
		}
	}
}