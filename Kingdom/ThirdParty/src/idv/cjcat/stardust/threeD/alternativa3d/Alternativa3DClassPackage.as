package idv.cjcat.stardust.threeD.alternativa3d {
	import idv.cjcat.stardust.common.xml.ClassPackage;
	import idv.cjcat.stardust.threeD.alternativa3d.handlers.Alternativa3DObject3DHandler;
	import idv.cjcat.stardust.threeD.alternativa3d.initializers.Alternativa3DObject3DClass;
	
	/**
	 * Packs together classes for the Stardust Alternativa3DClassPackage extension.
	 *
	 * <p>
	 * To enable XML support for this extension, use the <code>XMLBuilder.registerClassesFromClassPackage()</code> method
	 * to register related classes to the <code>XMLBuilder</code> object first.
	 * </p>
	 *
	 */
	public class Alternativa3DClassPackage extends ClassPackage {
		
		private static var _instance:Alternativa3DClassPackage;
		
		public static function getInstance():Alternativa3DClassPackage {
			if (!_instance) _instance = new Alternativa3DClassPackage();
			return _instance;
		}
		
		public function Alternativa3DClassPackage() {
			
		}
		
		
		override protected final function populateClasses():void {
			//Alternativa3D initializers
			classes.push(Alternativa3DObject3DClass);
			
			//Alternativa3D particle handlers
			classes.push(Alternativa3DObject3DHandler);
		}
	}
}