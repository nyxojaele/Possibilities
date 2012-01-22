package managers.city.buildings 
{
	import managers.resources.Resource_Gold;
	import managers.resources.ResourceCollection;
	/**
	 * ...
	 * @author Jed Lang
	 */
	public class Building_Barracks extends Building 
	{
		private static const _name:String = "Barracks";
		public static function get name():String { return _name; }
		private static const _resourceCost:ResourceCollection = new ResourceCollection(1, 1, 1);
		public static function get resourceCost():ResourceCollection { return _resourceCost; }
		private static const _maxHealth:Number = 150;
		public static function get maxHealth():Number { return _maxHealth; }
		
		public function Building_Barracks(id:int=-1) 
		{
			super(id, "data/gfx/buildings/barracks.png", null, 2, 2, Building_Barracks.name, Building_Barracks.maxHealth, 1);
		}
		
	}

}