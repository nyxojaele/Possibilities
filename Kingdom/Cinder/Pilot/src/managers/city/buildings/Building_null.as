package managers.city.buildings 
{
	import managers.resources.ResourceCollection;
	/**
	 * ...
	 * @author Jed Lang
	 */
	public class Building_null extends Building 
	{
		[Embed(source = "../../../data/gfx/buildings/blankTile.png", mimeType="image/png")]
		private static const HILITE_PNG:Class;
		
		
		private static const _instance:Building_null = new Building_null();
		public static function get instance():Building_null { return _instance; }
		
		
		public function Building_null() 
		{
			super(-1, null, HILITE_PNG, 1, 1, "", 1);
		}
	}
}