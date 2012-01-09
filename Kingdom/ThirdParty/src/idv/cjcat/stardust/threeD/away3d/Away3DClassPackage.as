package idv.cjcat.stardust.threeD.away3d {
	import idv.cjcat.stardust.common.xml.ClassPackage;
	import idv.cjcat.stardust.threeD.away3d.handlers.Away3DObject3DHandler;
	import idv.cjcat.stardust.threeD.away3d.handlers.Away3DSprite3DHandler;
	import idv.cjcat.stardust.threeD.away3d.initializers.Away3DObject3DClass;
	import idv.cjcat.stardust.threeD.away3d.initializers.Away3DSprite3DClass;
	
	/**
	 * Packs together classes for the Stardust Away3DClassPackage extension.
	 *
	 * <p>
	 * To enable XML support for this extension, use the <code>XMLBuilder.registerClassesFromClassPackage()</code> method
	 * to register related classes to the <code>XMLBuilder</code> object first.
	 * </p>
	 *
	 */
	public class Away3DClassPackage extends ClassPackage {
		
		private static var _instance:Away3DClassPackage;
		
		public static function getInstance():Away3DClassPackage {
			if (!_instance) _instance = new Away3DClassPackage();
			return _instance;
		}
		
		public function Away3DClassPackage() {
			
		}
		
		
		override protected final function populateClasses():void {
			//Away3D initializers
			classes.push(Away3DObject3DClass);
			classes.push(Away3DSprite3DClass);
			
			//Away3D renderers
			classes.push(Away3DObject3DHandler);
			classes.push(Away3DSprite3DHandler);
		}
	}
}