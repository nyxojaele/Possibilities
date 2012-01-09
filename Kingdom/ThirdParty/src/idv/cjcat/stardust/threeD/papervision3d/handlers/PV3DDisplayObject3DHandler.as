package idv.cjcat.stardust.threeD.papervision3d.handlers {
	import idv.cjcat.stardust.common.handlers.ParticleHandler;
	import idv.cjcat.stardust.common.particles.Particle;
	import idv.cjcat.stardust.threeD.particles.Particle3D;
	import org.papervision3d.objects.DisplayObject3D;
	
	/**
	 * This handler adds <code>DisplayObject3D</code> particles to a <code>DisplayObject3D</code> container, 
	 * removes dead particles from the container, 
	 * and updates the <code>DisplayObject3D</code> objects' x, y, z, rotationX, rotationY, rotationZ, scaleX, scaleY, scaleZ, and alpha properties.
	 */
	public class PV3DDisplayObject3DHandler extends ParticleHandler {
		
		private var container:DisplayObject3D;
		
		public function PV3DDisplayObject3DHandler(container:DisplayObject3D = null) {
			this.container = container;
		}
		
		private var do3D:DisplayObject3D;
		private var parent:DisplayObject3D;
		
		override public function particleAdded(particle:Particle):void {
			do3D = DisplayObject3D(particle.target);
			container.addChild(do3D);
			particle.dictionary[PV3DDisplayObject3DHandler] = container;
		}
		
		override public function particleRemoved(particle:Particle):void {
			do3D = DisplayObject3D(particle.target);
			parent = DisplayObject3D(particle.dictionary[PV3DDisplayObject3DHandler]);
			
			//working, but still doesn't completely solve the Papervision3D memory leak
			//probably need to wait for an official patch
			if (do3D.material) {
				do3D.material.unregisterObject(do3D);
			}
			if (do3D.materials) {
				for each (var matName:String in do3D.materialsList()) {
					do3D.materials.getMaterialByName(matName).unregisterObject(do3D);
				}
			}
			do3D.geometry.vertices = null;
			do3D.geometry.faces = null;
			do3D.faces = null;
			
			parent.removeChild(do3D);
		}
		
		private var p3D:Particle3D;
		
		override public function readParticle(particle:Particle):void {
			p3D = Particle3D(particle);
			
			do3D = DisplayObject3D(particle.target);
			do3D.x = p3D.x;
			do3D.y = p3D.y;
			do3D.z = p3D.z;
			do3D.rotationX = p3D.rotationX;
			do3D.rotationY = p3D.rotationY;
			do3D.rotationZ = p3D.rotationZ;
			do3D.scaleX = do3D.scaleY = do3D.scaleZ = particle.scale;
			do3D.alpha = particle.alpha;
		}
		
		
		//XML
		//------------------------------------------------------------------------------------------------
		
		override public function getXMLTagName():String {
			return "PV3DDisplayObject3DHandler";
		}
		
		//------------------------------------------------------------------------------------------------$
		//end of XML
	}
}