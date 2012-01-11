package managers.city.buildings 
{
	import managers.resources.ResourceCollection;
	/**
	 * ...
	 * @author Jed Lang
	 */
	public class Building_MageTower extends Building 
	{
		private static const _name:String = "Mage Tower";
		public static function get name():String { return _name; }
		private static const _resourceCost:ResourceCollection = new ResourceCollection(10, 0, 5);
		public static function get resourceCost():ResourceCollection { return _resourceCost; }
		private static const _maxHealth:Number = 50;
		public static function get maxHealth():Number { return _maxHealth; }
		
		public function Building_MageTower(id:int=-1) 
		{
			super(id, "data/gfx/buildings/magetower.png", null, 1, 1, Building_MageTower.name, Building_MageTower.maxHealth, 1);
		}
		
	}

}