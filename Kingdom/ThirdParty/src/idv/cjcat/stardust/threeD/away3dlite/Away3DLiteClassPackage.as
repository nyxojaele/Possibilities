package idv.cjcat.stardust.threeD.away3dlite {
	import idv.cjcat.stardust.common.xml.ClassPackage;
	import idv.cjcat.stardust.threeD.away3dlite.handlers.Away3DLiteObject3DHandler;
	import idv.cjcat.stardust.threeD.away3dlite.initializers.Away3DLiteObject3DClass;
	
	/**
	 * Packs together classes for the Stardust Away3DClassPackage extension.
	 *
	 * <p>
	 * To enable XML support for this extension, use the <code>XMLBuilder.registerClassesFromClassPackage()</code> method
	 * to register related classes to the <code>XMLBuilder</code> object first.
	 * </p>
	 *
	 */
	public class Away3DLiteClassPackage extends ClassPackage {
		
		private static var _instance:Away3DLiteClassPackage;
		
		public static function getInstance():Away3DLiteClassPackage {
			if (!_instance) _instance = new Away3DLiteClassPackage();
			return _instance;
		}
		
		public function Away3DLiteClassPackage() {
			
		}
		
		
		override protected final function populateClasses():void {
			//Away3D Lite initializers
			classes.push(Away3DLiteObject3DClass);
			
			//Away3D Lite renderers
			classes.push(Away3DLiteObject3DHandler);
		}
	}
}