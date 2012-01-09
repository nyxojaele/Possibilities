package idv.cjcat.stardust.threeD.nd3d {
	import idv.cjcat.stardust.common.xml.ClassPackage;
	import idv.cjcat.stardust.threeD.nd3d.handlers.ND3DObject3DHandler;
	import idv.cjcat.stardust.threeD.nd3d.initializers.ND3DObject3DClass;

	/**
	 * Packs together classes for the Stardust ND3D extension.
	 * 
	 * <p>
	 * To enable XML support for this extension, use the <code>XMLBuilder.registerClassesFromClassPackage()</code> method 
	 * to register related classes to the <code>XMLBuilder</code> object first.
	 * </p>
	 */
	public class ND3DClassPackage extends ClassPackage {
		
		private static var _instance:ND3DClassPackage;
		
		public static function getInstance():ND3DClassPackage {
			if (!_instance) _instance = new ND3DClassPackage();
			return _instance;
		}
		
		public function ND3DClassPackage() {
			
		}
		
		
		override protected final function populateClasses():void {
			//ND3D initializers
			classes.push(ND3DObject3DClass);
			
			//ND3D particle handlers
			classes.push(ND3DObject3DHandler);
		}
	}
}