package idv.cjcat.stardust.threeD.papervision3d {
	import idv.cjcat.stardust.common.xml.ClassPackage;
	import idv.cjcat.stardust.threeD.papervision3d.handlers.PV3DDisplayObject3DHandler;
	import idv.cjcat.stardust.threeD.papervision3d.handlers.PV3DDisplayObjectHandler;
	import idv.cjcat.stardust.threeD.papervision3d.handlers.PV3DParticleHandler;
	import idv.cjcat.stardust.threeD.papervision3d.handlers.PV3DPixelsHandler;
	import idv.cjcat.stardust.threeD.papervision3d.initializers.PV3DDisplayObject3DClass;
	import idv.cjcat.stardust.threeD.papervision3d.initializers.PV3DDisplayObjectClass;
	import idv.cjcat.stardust.threeD.papervision3d.initializers.PV3DParticle;
	
	/**
	 * Packs together classes for the Stardust Papervision3D extension.
	 * 
	 * <p>
	 * To enable XML support for this extension, use the <code>XMLBuilder.registerClassesFromClassPackage()</code> method 
	 * to register related classes to the <code>XMLBuilder</code> object first.
	 * </p>
	 */
	public class PV3DClassPackage extends ClassPackage {
		
		private static var _instance:PV3DClassPackage;
		
		public static function getInstance():PV3DClassPackage {
			if (!_instance) _instance = new PV3DClassPackage();
			return _instance;
		}
		
		public function PV3DClassPackage() {
			
		}
		
		
		override protected final function populateClasses():void {
			//Papervision3D initializers
			classes.push(PV3DDisplayObject3DClass);
			classes.push(PV3DDisplayObjectClass);
			classes.push(PV3DParticle);
			
			//Papervision3D particle handlers
			classes.push(PV3DDisplayObject3DHandler);
			classes.push(PV3DDisplayObjectHandler);
			classes.push(PV3DParticleHandler);
			classes.push(PV3DPixelsHandler);
		}
	}
}