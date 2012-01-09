package states.play.actors.playgrid
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Jed Lang
	 */
	public class PlayGridEvent extends Event 
	{
		//PlayGridEvent Constants
		public static const PLAYGRID_PLACEMENTATMOUSE_CHANGED:String = "PlayGrid_PlacementAtMouse_Changed";
		public static const PLAYGRID_HILITEATMOUSE_CHANGED:String = "PlayGrid_HiliteAtMouse_Changed";
		
		
		public function PlayGridEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) 
		{ 
			super(type, bubbles, cancelable);
		} 
		
		public override function clone():Event 
		{ 
			return new PlayGridEvent(type, bubbles, cancelable);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("PlayGridEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}