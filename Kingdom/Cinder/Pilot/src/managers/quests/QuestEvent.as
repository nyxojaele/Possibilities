package managers.quests 
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Jed Lang
	 */
	public class QuestEvent extends Event 
	{
		//Event Constants
		public static const QUEST_BECAMEAVAILABLE:String = "Quest_BecameAvailable";
		public static const QUEST_STARTED:String = "Quest_Started";
		public static const QUEST_UPDATED:String = "Quest_Updated";
		public static const QUEST_COMPLETE:String = "Quest_Complete";
		
		
		public var quest:Quest = null;
		public var questId:uint = NaN;
		
		
		public function QuestEvent(type:String, quest:Quest, questId:uint, bubbles:Boolean=false, cancelable:Boolean=false) 
		{
			this.quest = quest;
			this.questId = questId;
			super(type, bubbles, cancelable);
			
		} 
		
		public override function clone():Event 
		{ 
			return new QuestEvent(type, quest, questId, bubbles, cancelable);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("QuestEvent", "type", "quest", "questId", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}