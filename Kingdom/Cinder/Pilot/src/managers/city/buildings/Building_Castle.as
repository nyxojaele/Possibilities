package managers.city.buildings 
{
	import managers.resources.ResourceCollection;
	/**
	 * ...
	 * @author Jed Lang
	 */
	public class Building_Castle extends Building 
	{
		private static const _name:String = "Castle";
		public static function get name():String { return _name; }
		private static const _resourceCost:ResourceCollection = new ResourceCollection(500, 500, 500);
		public static function get resourceCost():ResourceCollection { return _resourceCost; }
		private static const _maxHealth:Number = 500;
		public static function get maxHealth():Number { return _maxHealth; }
		
		public function Building_Castle(id:int=-1) 
		{
			super(id, "data/gfx/buildings/castle.png", null, 2, 2, Building_Castle.name, Building_Castle.maxHealth);
		}
		
	}

}