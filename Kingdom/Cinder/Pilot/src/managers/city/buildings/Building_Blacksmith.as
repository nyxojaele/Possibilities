package managers.city.buildings 
{
	import managers.resources.ResourceCollection;
	/**
	 * ...
	 * @author Jed Lang
	 */
	public class Building_Blacksmith extends Building 
	{
		private static const _name:String = "Blacksmith";
		public static function get name():String { return _name; }
		private static const _resourceCost:ResourceCollection = new ResourceCollection(1, 1, 1);
		public static function get resourceCost():ResourceCollection { return _resourceCost; }
		private static const _maxHealth:Number = 150;
		public static function get maxHealth():Number { return _maxHealth; }
		
		public function Building_Blacksmith(id:int=-1) 
		{
			super(id, "data/gfx/buildings/blacksmith.png", null, 2, 2, Building_Blacksmith.name, Building_Blacksmith.maxHealth, 1);
		}
		
	}

}