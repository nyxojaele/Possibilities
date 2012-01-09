package idv.cjcat.stardust.threeD.papervision3d.handlers {
	import idv.cjcat.stardust.common.handlers.ParticleHandler;
	import idv.cjcat.stardust.common.particles.Particle;
	import idv.cjcat.stardust.threeD.particles.Particle3D;
	import org.papervision3d.core.geom.Pixels;
	import org.papervision3d.core.geom.renderables.Pixel3D;
	
	public class PV3DPixelsHandler extends ParticleHandler {
		
		private var container:Pixels;
		
		public function PV3DPixelsHandler(container:Pixels = null) {
			this.container = container;
		}
		
		private var pixel:Pixel3D;
		
		override public function particleAdded(particle:Particle):void {
			pixel = Pixel3D(particle.target);
			container.addPixel3D(pixel);
			particle.dictionary[PV3DPixelsHandler] = container;
		}
		
		override public function particleRemoved(particle:Particle):void {
			pixel = Pixel3D(particle.target);
			container.removePixel3D(pixel);
		}
		
		private var p3D:Particle3D;
		
		override public function readParticle(particle:Particle):void {
			p3D = Particle3D(particle);
			
			pixel = Pixel3D(particle.target);
			pixel.x = p3D.x;
			pixel.y = p3D.y;
			pixel.z = p3D.z;
		}
		
		
		//XML
		//------------------------------------------------------------------------------------------------
		
		override public function getXMLTagName():String {
			return "PV3DPixelsHandler";
		}
		
		//------------------------------------------------------------------------------------------------$
		//end of XML
	}
}