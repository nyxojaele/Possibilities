package idv.cjcat.stardust.threeD.nd3d.handlers {
	import de.nulldesign.nd3d.objects.Object3D;
	import idv.cjcat.stardust.common.handlers.ParticleHandler;
	import idv.cjcat.stardust.common.math.StardustMath;
	import idv.cjcat.stardust.common.particles.Particle;
	import idv.cjcat.stardust.threeD.particles.Particle3D;
	
	/**
	 * This handler adds <code>Object3D</code> particles to a render list, 
	 * removes dead particles from the render list, 
	 * and updates the <code>Object3D</code> objects' x, y, z, angleX, angleY, angleZ, scaleX, scaleY, and scaleZ properties.
	 */
	public class ND3DObject3DHandler extends ParticleHandler {
		
		public var renderList:Array;
		
		/**
		 * 
		 * @param	renderList  The render list.
		 */
		public function ND3DObject3DHandler(renderList:Array) {
			this.renderList = renderList;
		}
		
		override public function particleAdded(particle:Particle):void {
			if (renderList.indexOf(particle.target) < 0) {
				renderList.push(particle.target);
			}
		}
		
		private var index:int;
		override public function particleRemoved(particle:Particle):void {
			if ((index = renderList.indexOf(particle.target)) >= 0) {
				renderList.splice(index, 1);
			}
		}
		
		private var p3D:Particle3D;
		private var obj:Object3D;
		
		override public function readParticle(particle:Particle):void {
			p3D = Particle3D(particle);
			obj = Object3D(particle.target);
				
			obj.xPos = p3D.x;
			obj.yPos = p3D.y;
			obj.zPos = p3D.z;
			obj.angleX = p3D.rotationX * StardustMath.DEGREE_TO_RADIAN;
			obj.angleY = p3D.rotationY * StardustMath.DEGREE_TO_RADIAN;
			obj.angleZ = p3D.rotationZ * StardustMath.DEGREE_TO_RADIAN;
			obj.scaleX = obj.scaleY = obj.scaleZ = particle.scale;
		}
		
		
		//XML
		//------------------------------------------------------------------------------------------------
		
		override public function getXMLTagName():String {
			return "ND3DObject3DHandler";
		}
		
		//------------------------------------------------------------------------------------------------$
		//end of XML
	}
}