package idv.cjcat.stardust.threeD.flare3d {
	import idv.cjcat.stardust.common.xml.ClassPackage;
	import idv.cjcat.stardust.threeD.flare3d.handlers.Flare3DPivot3DHandler;
	import idv.cjcat.stardust.threeD.flare3d.handlers.Flare3DSprite3DHandler;
	import idv.cjcat.stardust.threeD.flare3d.initializers.Flare3DPivot3DClass;
	import idv.cjcat.stardust.threeD.flare3d.initializers.Flare3DPivot3DClone;
	import idv.cjcat.stardust.threeD.flare3d.initializers.Flare3DSprite3D;
	
	/**
	 * Packs together classes for the Stardust Flare3D extension.
	 * 
	 * <p>
	 * To enable XML support for this extension, use the <code>XMLBuilder.registerClassesFromClassPackage()</code> method 
	 * to register related classes to the <code>XMLBuilder</code> object first.
	 * </p>
	 */
	public class Flare3DClassPackage extends ClassPackage {
		
		private static var _instance:Flare3DClassPackage;
		
		public static function getInstance():Flare3DClassPackage {
			if (!_instance) _instance = new Flare3DClassPackage();
			return _instance;
		}
		
		public function Flare3DClassPackage() {
			
		}
		
		
		override protected final function populateClasses():void {
			//Papervision3D initializers
			classes.push(Flare3DPivot3DClass);
			classes.push(Flare3DPivot3DClone);
			classes.push(Flare3DSprite3D);
			
			//Papervision3D particle handlers
			classes.push(Flare3DPivot3DHandler);
			classes.push(Flare3DSprite3DHandler);
		}
	}
}