package idv.cjcat.stardust.threeD.flare3d.handlers {
	import flare.core.Mesh3D;
	import flare.core.Sprite3D;
	import flare.core.Vertex3D;
	import idv.cjcat.stardust.common.handlers.ParticleHandler;
	import idv.cjcat.stardust.common.particles.Particle;
	import idv.cjcat.stardust.threeD.flare3d.Flare3DVertex3DSprite3DPair;
	import idv.cjcat.stardust.threeD.particles.Particle3D;
	
	/**
	 * This handler adds <code>Sprite3D</code> particles to a <code>Mesh</code> container, 
	 * removes dead particles from the container, 
	 * and updates the <code>Sprite3D</code> objects' x, y, z, scaleX, and scaleY properties.
	 */
	public class Flare3DSprite3DHandler extends ParticleHandler {
		
		public var container:Mesh3D;
		
		public function Flare3DSprite3DHandler(container:Mesh3D = null) {
			this.container = container;
		}
		
		private var pair:Flare3DVertex3DSprite3DPair;
		private var mesh:Mesh3D;
		
		override public function particleAdded(particle:Particle):void {
			pair = Flare3DVertex3DSprite3DPair(particle.target);
			container.addVertex(pair.vertex3D);
			container.addPoly(pair.sprite3D);
			particle.dictionary[Flare3DSprite3DHandler] = container;
		}
		
		override public function particleRemoved(particle:Particle):void {
			pair = Flare3DVertex3DSprite3DPair(particle.target);
			mesh = Mesh3D(particle.dictionary[Flare3DSprite3DHandler]);
			mesh.removeVertex(pair.vertex3D);
			mesh.removePoly(pair.sprite3D);
		}
		
		private var p3D:Particle3D;
		private var v3D:Vertex3D;
		private var s3D:Sprite3D;
		
		override public function readParticle(particle:Particle):void {
			p3D = Particle3D(particle);
			
			pair = Flare3DVertex3DSprite3DPair(particle.target);
				
			v3D = pair.vertex3D;
			s3D = pair.sprite3D;
			
			v3D.x = p3D.x;
			v3D.y = p3D.y;
			v3D.z = p3D.z;
			s3D.scaleX = s3D.scaleY = particle.scale;
		}
		
		
		//XML
		//------------------------------------------------------------------------------------------------
		
		override public function getXMLTagName():String {
			return "Flare3DSprite3DHandler";
		}
		
		//------------------------------------------------------------------------------------------------$
		//end of XML
	}
}