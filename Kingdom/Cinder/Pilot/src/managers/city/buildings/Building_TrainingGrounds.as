package managers.city.buildings 
{
	import managers.resources.ResourceCollection;
	/**
	 * ...
	 * @author Jed Lang
	 */
	public class Building_TrainingGrounds extends Building 
	{
		private static const _name:String = "Training Grounds";
		public static function get name():String { return _name; }
		private static const _resourceCost:ResourceCollection = new ResourceCollection(1, 1, 1);
		public static function get resourceCost():ResourceCollection { return _resourceCost; }
		private static const _maxHealth:Number = 100;
		public static function get maxHealth():Number { return _maxHealth; }
		
		public function Building_TrainingGrounds(id:int=-1) 
		{
			super(id, "data/gfx/buildings/traininggrounds.png", null, 2, 2, Building_TrainingGrounds.name, Building_TrainingGrounds.maxHealth, 1);
		}
		
	}

}