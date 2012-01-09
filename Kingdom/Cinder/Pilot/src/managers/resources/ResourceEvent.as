package managers.resources 
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Jed Lang
	 */
	public class ResourceEvent extends Event 
	{
		//Event Constants
		public static const RESOURCE_AMOUNTCHANGED:String = "Resource_AmountChanged";
		
		
		public var resource:uint;
		public var newAmount:Number;
		
		
		public function ResourceEvent(type:String, resource:uint=-1, newAmount:Number=-1, bubbles:Boolean=false, cancelable:Boolean=false) 
		{ 
			super(type, bubbles, cancelable);
			this.resource = resource;
			this.newAmount = newAmount;
		} 
		
		public override function clone():Event 
		{ 
			return new ResourceEvent(type, resource, newAmount, bubbles, cancelable);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("ResourceEvent", "resource", "newAmount", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}