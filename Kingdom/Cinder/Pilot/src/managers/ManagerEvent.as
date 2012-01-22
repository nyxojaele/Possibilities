package managers 
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Jed Lang
	 */
	public class ManagerEvent extends Event 
	{
		//Event Constants
		public static const MANAGER_REQUESTRETURN:String = "Manager_RequestReturn";		//Request has returned from server
		public static const MANAGER_SERVERLOADSTART:String = "Manager_ServerLoadStart";	//"success" - beginning to hydrate values
		public static const MANAGER_SERVERLOADEND:String = "Manager_ServerLoadEnd";		//"success" - everything complete
		public static const MANAGER_SERVERERROR:String = "Manager_ServerError";			//"failure" - cancelled altogether
		public static const MANAGER_ITEMIDUPDATED:String = "Manager_ItemIDUpdated";		//An item ID has been updated from the server
		
		
		public var data:String;
		
		
		public function ManagerEvent(type:String, data:String="", bubbles:Boolean=false, cancelable:Boolean=false) 
		{ 
			super(type, bubbles, cancelable);
			this.data = data;
		} 
		
		public override function clone():Event 
		{ 
			return new ManagerEvent(type, data, bubbles, cancelable);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("ManagerEvent", "type", "data", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}