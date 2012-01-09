package idv.cjcat.stardust.threeD.flare3d {
	import flare.core.Sprite3D;
	import flare.core.Vertex3D;
	
	/** @private */
	public class Flare3DVertex3DSprite3DPair {
		
		public var vertex3D:Vertex3D;
		public var sprite3D:Sprite3D
		
		public function Flare3DVertex3DSprite3DPair(vertex3D:Vertex3D, sprite3D:Sprite3D) {
			this.vertex3D = vertex3D;
			this.sprite3D = sprite3D;
		}
	}
}