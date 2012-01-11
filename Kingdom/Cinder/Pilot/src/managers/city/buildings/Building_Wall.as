package managers.city.buildings 
{
	import managers.resources.ResourceCollection;
	/**
	 * ...
	 * @author Jed Lang
	 */
	public class Building_Wall extends Building 
	{
		private static const _name:String = "Wall";
		public static function get name():String { return _name; }
		private static const _resourceCost:ResourceCollection = new ResourceCollection(50, 10, 5);
		public static function get resourceCost():ResourceCollection { return _resourceCost; }
		private static const _maxHealth:Number = 40;
		public static function get maxHealth():Number { return _maxHealth; }
		
		public function Building_Wall(id:int=-1) 
		{
			super(id, "data/gfx/buildings/wall.png", null, 1, 1, Building_Wall.name, Building_Wall.maxHealth, 1);
		}
		
	}

}