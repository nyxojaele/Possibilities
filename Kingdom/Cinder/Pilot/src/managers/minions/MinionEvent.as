package managers.minions 
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Jed Lang
	 */
	public class MinionEvent extends Event 
	{
		public static const MINION_ADDED:String = "Minion_Added";
		public static const MINION_REMOVED:String = "Minion_Removed";
		public static const MINION_QUESTSET:String = "Minion_QuestSet";
		
		
		public var minion:Minion;
		
		
		public function MinionEvent(type:String, minion:Minion, bubbles:Boolean=false, cancelable:Boolean=false) 
		{ 
			super(type, bubbles, cancelable);
			this.minion = minion;
		} 
		
		public override function clone():Event 
		{ 
			return new MinionEvent(type, minion, bubbles, cancelable);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("MinionEvent", "minion", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}