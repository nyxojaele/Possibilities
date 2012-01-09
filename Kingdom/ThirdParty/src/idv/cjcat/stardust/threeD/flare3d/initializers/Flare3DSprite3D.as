package idv.cjcat.stardust.threeD.flare3d.initializers {
	import flare.core.Sprite3D;
	import flare.core.Vertex3D;
	import flare.materials.SpriteTextureMaterial;
	import idv.cjcat.stardust.common.particles.Particle;
	import idv.cjcat.stardust.threeD.flare3d.Flare3DVertex3DSprite3DPair;
	import idv.cjcat.stardust.threeD.initializers.Initializer3D;
	
	/**
	 * Assigns a <code>Sprite3D</code> object to the <code>target</code> properties of a particle. 
	 * This information can be visualized by <code>Flare3DSprite3DRenderer</code>.
	 * 
	 * @see idv.cjcat.stardust.threeD.flare3d.renderers.Flare3DSprite3DRenderer
	 */
	public class Flare3DSprite3D extends Initializer3D {
		
		private var _material:SpriteTextureMaterial;
		
		public function Flare3DSprite3D(material:SpriteTextureMaterial) {
			this.material = material;
		}
		
		public function get material():SpriteTextureMaterial { return _material; }
		public function set material(value:SpriteTextureMaterial):void {
			if (!value) value = new SpriteTextureMaterial();
			_material = value;
		}
		
		override public final function initialize(particle:Particle):void {
			var v3D:Vertex3D = new Vertex3D();
			var s3D:Sprite3D = new Sprite3D(v3D, 10, 10, _material);
			
			particle.target = new Flare3DVertex3DSprite3DPair(v3D, s3D);
		}
		
		
		//XML
		//------------------------------------------------------------------------------------------------
		
		override public function getXMLTagName():String {
			return "Flare3DSprite3D";
		}
		
		//------------------------------------------------------------------------------------------------
		//end of XML
	}
}