package managers.city.buildings 
{
	import managers.resources.ResourceCollection;
	/**
	 * ...
	 * @author Jed Lang
	 */
	public class Building_Fence extends Building 
	{
		private static const _name:String = "Fence";
		public static function get name():String { return _name; }
		private static const _resourceCost:ResourceCollection = new ResourceCollection(10, 1, 0);
		public static function get resourceCost():ResourceCollection { return _resourceCost; }
		private static const _maxHealth:Number = 10;
		public static function get maxHealth():Number { return _maxHealth; }
		
		public function Building_Fence(id:int=-1) 
		{
			super(id, "data/gfx/buildings/fence.png", null, 1, 1, Building_Fence.name, Building_Fence.maxHealth);
		}
		
	}

}