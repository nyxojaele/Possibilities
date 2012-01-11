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
		protected const QUESTTYPE_REALTIME:uint = 1;
		protected const QUESTTYPE_GAMETIME:uint = 2;
		protected const QUESTTYPE_STEP:uint = 3;
		
		
		//These values reflect what the quest's current state is
		public static const QUESTSTATE_NONE:uint = 0;
		public static const QUESTSTATE_AVAILABLE:uint = 1;
		public static const QUESTSTATE_STARTED:uint = 2;
		public static const QUESTSTATE_FINISHED:uint = 3;
		
		
		protected var _questId:Number = -1;
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
		private var _description:String = "";
		public function get description():String { return _description; }
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
		
		
		public function Quest(id:Number, questId:uint, name:String, description:String, xPos:Number, yPos:Number,
			rewardResources:ResourceCollection, rewardMinions:MinionBuilderCollection, rewardMinionStats:MinionStatCollection)
		{
			super(id);
			_questId = questId;
			
			_name = name;
			_description = description;
			
			_x = xPos;
			_y = yPos;
			
			if (rewardResources)
				rewards.push(new Reward(rewardResources, ResourceManager.instance));
			if (rewardMinions)
				rewards.push(new Reward(rewardMinions, MinionManager.instance));
			if (rewardMinionStats)
				rewards.push(new Reward(rewardMinionStats, MinionManager.instance));
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
		//This is called on creation so the quest can listen for the correct events
		public function setupListeners(questId:uint):void{ }
		
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