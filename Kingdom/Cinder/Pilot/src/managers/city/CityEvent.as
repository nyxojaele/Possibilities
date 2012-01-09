package managers.city 
{
	import flash.events.Event;
	import managers.city.buildings.Building;
	
	/**
	 * ...
	 * @author Jed Lang
	 */
	public class CityEvent extends Event 
	{
		public static const CITY_BUILDING_PLACED:String = "City_Building_Placed";
		public static const CITY_BUILDING_REMOVED:String = "City_Building_Removed";
		
		
		public var building:Building = null;
		
		
		public function CityEvent(type:String, building:Building, bubbles:Boolean=false, cancelable:Boolean=false) 
		{ 
			super(type, bubbles, cancelable);
			this.building = building;
		} 
		
		public override function clone():Event 
		{ 
			return new CityEvent(type, building, bubbles, cancelable);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("CityEvent", "type", "building", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}