package managers.city.buildings 
{
	import managers.resources.ResourceCollection;
	/**
	 * ...
	 * @author Jed Lang
	 */
	public class Building_Quarters extends Building 
	{
		private static const _name:String = "Quarters";
		public static function get name():String { return _name; }
		private static const _resourceCost:ResourceCollection = new ResourceCollection(1, 1, 1);
		public static function get resourceCost():ResourceCollection { return _resourceCost; }
		private static const _maxHealth:Number = 50;
		public static function get maxHealth():Number { return _maxHealth; }
		
		public function Building_Quarters(id:int=-1) 
		{
			super(id, "data/gfx/buildings/quarters.png", null, 1, 1, Building_Quarters.name, Building_Quarters.maxHealth, 1);
		}
	}

}