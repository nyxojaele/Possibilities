package states.play 
{
	import flash.events.Event;
	import managers.city.buildings.Building;
	
	/**
	 * ...
	 * @author Jed Lang
	 */
	public class WorldViewEvent extends Event 
	{
		public var building:Building;
		
		//Event constants
		public static const WORLD_BUILDING_HILITED:String = "World_Building_Hilited";
		public static const WORLD_BUILDING_HOLDING:String = "World_Building_Holding";
		public static const WORLD_BUILDING_CANCELLED:String = "World_Building_Cancelled";
		
		
		public function WorldViewEvent(type:String, building:Building, bubbles:Boolean=false, cancelable:Boolean=false) 
		{ 
			super(type, bubbles, cancelable);
			
			this.building = building;
		} 
		
		public override function clone():Event 
		{ 
			return new WorldViewEvent(type, building, bubbles, cancelable);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("WorldViewEvent", "building", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}