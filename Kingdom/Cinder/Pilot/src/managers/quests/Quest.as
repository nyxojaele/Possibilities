package managers.quests 
{
	import flash.net.URLVariables;
	import managers.ManagedItem;
	import managers.MinionManager;
	import managers.minions.MinionBuilderCollection;
	import managers.minions.MinionStatCollection;
	import managers.ResourceManager;
	import managers.resources.ResourceCollection;
	/**
	 * ...
	 * @author Jed Lang
	 */
	public class Quest extends ManagedItem
	{
		//These values are used only for passing to the server so it knows what extra values to save
		protected static const QUESTTYPE_REALTIME:uint = 1;
		protected static const QUESTTYPE_GAMETIME:uint = 2;
		protected static const QUESTTYPE_STEP:uint = 3;
		
		
		//These values reflect what the quest's current state is
		public static const QUESTSTATE_NONE:uint = 0;
		public static const QUESTSTATE_AVAILABLE:uint = 1;
		public static const QUESTSTATE_STARTED:uint = 2;
		public static const QUESTSTATE_FINISHED:uint = 3;
		
		
		protected var _questId:Number = -1;
		public function get questId():Number { return _questId; }
		//If this is true after an update, the QuestManager should send an update to the server about this quest
		protected var _shouldUpdateServer:Boolean = false;
		public function get shouldUpdateServer():Boolean { return _shouldUpdateServer; }
		public function setShouldUpdateServer(value:Boolean):void { _shouldUpdateServer = value; }
		//Marks whether the current state of the quest's values has changed since the last time the quest has been updated
		protected var _updatePending:Boolean = false;
		public function get updatePending():Boolean { return _updatePending; }
		private var _state:uint = 0;
		public function get state():uint { return _state; }
		public function setState(value:uint):void { _state = value; }
		
		private var _name:String = "";
		public function get name():String { return _name; }
		private var _repeatable:Boolean = false;
		public function get repeatable():Boolean { return _repeatable; }
		private var _description:String = "";
		public function get description():String { return _description; }
		private var _completeText:String = "";
		public function get completeText():String { return _completeText; }
		//These values should be overridden in derived classes so they return something useful
		public function get percentDone():Number { return 0; }	//For progress bar, etc...
		public function get valueCurrent():Number { return 0; }	//For server persistence
		public function get valueGoal():Number { return 0; }	//For server persistence
		//Position on map
		private var _x:Number = 0;
		public function get x():Number { return _x; }
		private var _y:Number = 0;
		public function get y():Number { return _y; }
		//Rewards
		private var _rewards:Array = [];
		public function get rewards():Array { return _rewards; }
		//Quest chain
		private var _unlocksQuestIds:Array = [];
		public function get unlocksQuestIds():Array { return _unlocksQuestIds; }
		//Requirements
		private var _requiredStats:MinionStatCollection = null;
		public function get requiredStats():MinionStatCollection { return _requiredStats; }
		
		
		public function Quest(id:Number, questId:uint, name:String, repeatable:Boolean, description:String, completeText:String, xPos:Number, yPos:Number,
			unlockQuestIds:Array,
			rewardResources:ResourceCollection, rewardMinions:MinionBuilderCollection, rewardMinionStats:MinionStatCollection,
			requiredStats:MinionStatCollection)
		{
			super(id);
			_questId = questId;
			
			_name = name;
			_repeatable = repeatable;
			_description = description;
			_completeText = completeText;
			
			_x = xPos;
			_y = yPos;
			
			if (rewardResources)
				rewards.push(new Reward(rewardResources, ResourceManager.instance));
			if (rewardMinions)
				rewards.push(new Reward(rewardMinions, MinionManager.instance));
			if (rewardMinionStats)
				rewards.push(new Reward(rewardMinionStats, MinionManager.instance));
			
			if (unlockQuestIds)
				_unlocksQuestIds = unlockQuestIds;
			
			_requiredStats = requiredStats;
		}
		
		
		//These functions should be overridden in derived classes, ignoring the super function from within the overrides
		public function start():void { }
		public function updateValue(value:*=null):void { }
		//Returns whether the quest is complete or not
		public function update():Boolean { return false; }
		public function reset():void { }
		public function populateAvailableRequest(request:URLVariables):void { }
		public function populateStartRequest(request:URLVariables):void { }
		public function populateUpdateRequest(request:URLVariables):void { }
		public function populateFinishRequest(request:URLVariables):void { }
		
		//These functions should be overridden in derived classes, but must also call the super function from within the overrides
		public function initFromServerData(properties:Array):Boolean
		{
			if (properties.length < 3 ||
				isNaN(Number(properties[2])))
				return false;
			_state = Number(properties[2]);
			return true;
		}
	}
}