package managers.city.buildings 
{
	import managers.resources.ResourceCollection;
	/**
	 * ...
	 * @author Jed Lang
	 */
	public class Building_Farm extends Building 
	{
		private static const _name:String = "Farm";
		public static function get name():String { return _name; }
		private static const _resourceCost:ResourceCollection = new ResourceCollection(10, 50, 50);
		public static function get resourceCost():ResourceCollection { return _resourceCost; }
		private static const _maxHealth:Number = 40;
		public static function get maxHealth():Number { return _maxHealth; }
		
		public function Building_Farm(id:int=-1) 
		{
			super(id, "data/gfx/buildings/farm.png", null, 2, 2, Building_Farm.name, Building_Farm.maxHealth, 1);
		}
		
	}

}