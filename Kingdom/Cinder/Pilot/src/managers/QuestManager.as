package managers 
{
	import com.adobe.protocols.dict.DictionaryServer;
	import com.junkbyte.console.Cc;
	import flash.net.URLVariables;
	import flash.utils.Dictionary;
	import managers.city.CityEvent;
	import managers.minions.MinionBuilderCollection;
	import managers.minions.MinionStatCollection;
	import managers.quests.GametimeQuest;
	import managers.quests.Quest;
	import managers.quests.QuestEvent;
	import managers.quests.RealtimeQuest;
	import managers.quests.Reward;
	import managers.quests.StepQuest;
	import managers.resources.ResourceCollection;
	/**
	 * ...
	 * @author Jed Lang
	 */
	public class QuestManager extends Manager implements IUpdatingManager
	{
		//Singleton
		private static var _instance:QuestManager;
		public static function get instance():QuestManager
		{
			if (!_instance)
			{
				initQuestLibrary();	//We need these in place before Quest Classes can be determined
				initQuestClasses();	//Because we can't use an initializer with a Dictionary (I think?)
				_instance = new QuestManager();
			}
			return _instance;
		}
		
		
		//The following consts and the array after must match each other
		//Indices must start as 0, as they're also used to index into _questLibrary
		public static const QUEST_MINIONHOUSING1:uint = 0;
		public static var questLibrary:Dictionary;//Contains every quest. Period.
		private static var questClasses:Dictionary;
		private static function initQuestLibrary():void
		{
			//Populate quest library
			questLibrary = new Dictionary();
			questLibrary[QUEST_MINIONHOUSING1] = new StepQuest( -1, QUEST_MINIONHOUSING1, "Construct Minion Housing",
				"It's going to be important that your minions have a place to sleep. Have one of your minions construct a house.",
				0, 0, 1, ResourceCollection.empty, MinionBuilderCollection.empty, new MinionStatCollection(0, 0, 0, 1));
				questLibrary[QUEST_MINIONHOUSING1].setupListeners(QUEST_MINIONHOUSING1);
			//questLibrary[QUEST_MINIONHOUSING1] = new RealtimeQuest(-1, "Realtime Test", "Testing a realtime timed quest", 80, 0, 30000);
			//questLibrary[QUEST_TIMEDTEST2] = new GametimeQuest(-1, "Gametime Test", "Testing a gametime timed quest", 80, 20, 5000);
			//questLibrary[QUEST_STEPTEST] = new StepQuest(-1, "Step Test", "Testing a step quest", 80, 40, 5);
		}
		private static function initQuestClasses():void
		{
			questClasses = new Dictionary();
			for (var idx:* in questLibrary)
			{
				questClasses[idx] = Object(questLibrary[idx]).constructor;
			}
		}
		
		private static function getQuestClassById(id:uint):Class
		{
			if (id >= questClasses.length)
				return null;
			return questClasses[id];
		}
		private static function getQuestIdByClass(cls:Class):int
		{
			for (var questId:* in questClasses)
			{
				var id:uint = questId as uint;
				if (questClasses[id] == cls)
					return id;
			}
			return -1;
		}
		
		
		private var _questsAvailable:Array;			//Contains only the quest ids that are available to be, but not yet, started.
		private var _questsToUpdate:Array;			//Contains only the quest ids that have been started but not finished yet.
		private var _questsComplete:Array;			//Contains only the quest ids that have completed
		
		
		public function QuestManager() 
		{
			super("quests.php", requestReturn);
			
			_questsAvailable = [];
			_questsToUpdate = [];
			_questsComplete = [];
		}
		
		
		//**********************************************************************
		//
		//                            SERVER DATA
		//
		//**********************************************************************
		protected override function getMemberClassByTypeId(typeId:uint):Class
		{
			return QuestManager.getQuestClassById(typeId);
		}
		protected override function hydrateMemberWithServerData(member:ManagedItem, properties:Array):Boolean
		{
			if (properties.length < 3 ||
				isNaN(Number(properties[2])) ||
				!(member is Quest))
				return false;
			
			var state:uint = Number(properties[2]);
			var workingQuest:Quest = member as Quest;
			var questId:Number = QuestManager.getQuestIdByClass(Object(workingQuest).constructor);
			var actualQuest:Quest = questLibrary[questId];
			
			actualQuest.setID(workingQuest.id);					//Pass on the id
			if (!actualQuest.initFromServerData(properties))	//Initialize quest
				return false;
			initQuestState(questId, actualQuest, state);		//This will fire an event for any listeners of QUEST_BECAMEAVAILABLE, QUEST_STARTED, or QUEST_COMPLETED
			return true;
		}
		
		
		private function initQuestState(questId:uint, quest:Quest, state:uint):void
		{
			switch (state)
			{
				case Quest.QUESTSTATE_NONE: //This shouldn't be getting retrieved from the server!
					{
						Cc.warn("Retrieved quest \"" + quest.name + "\" from server with state 0");
						break;
					}
				case Quest.QUESTSTATE_AVAILABLE:
					{
						_questsAvailable.push(questId);
						dispatchEvent(new QuestEvent(QuestEvent.QUEST_BECAMEAVAILABLE, quest, questId));
						break;
					}
				case Quest.QUESTSTATE_STARTED:
					{
						_questsToUpdate.push(questId);
						dispatchEvent(new QuestEvent(QuestEvent.QUEST_STARTED, quest, questId));
						break;
					}
				case Quest.QUESTSTATE_FINISHED:
					{
						_questsComplete.push(questId);
						dispatchEvent(new QuestEvent(QuestEvent.QUEST_COMPLETE, quest, questId));
						break;
					}
			}
		}
		
		private function sendQuestAvailableRequest(quest:Quest):void
		{
			quest.setID(-Manager.requestID);	//Done before makeRequest so we get the value before it's incremented.
			//This should always be the first thing done for a quest in the DB,
			//so this is how it gets instantiated.
			var request:URLVariables = makeRequest("available");
			if (request)
			{
				request.classTypeID = QuestManager.getQuestIdByClass(Object(quest).constructor);
				quest.populateAvailableRequest(request);
				sendRequest(request);
			}
		}
		private function sendQuestStartedEvent(quest:Quest):void
		{
			//The quest rows should always be instantiated at this point, so we only need to modify it in the DB.
			var request:URLVariables = makeRequest("start");
			if (request)
			{
				request.id = quest.id;
				quest.populateStartRequest(request);
				sendRequest(request);
			}
		}
		private function sendQuestUpdateRequest(quest:Quest):void
		{
			//The quest rows should always be instantiated at this point, so we only need to modify it in the DB.
			var request:URLVariables = makeRequest("update");
			if (request)
			{
				request.id = quest.id;
				quest.populateUpdateRequest(request);
				sendRequest(request);
			}
		}
		private function sendQuestFinishedEvent(quest:Quest):void
		{
			//The quest rows should always be instantiated at this point, so we only need to modify it in the DB.
			var request:URLVariables = makeRequest("finish");
			if (request)
			{
				request.id = quest.id;
				quest.populateFinishRequest(request);
				sendRequest(request);
			}
		}
		private function sendQuestResetRequest(quest:Quest):void
		{
			//The quest rows may or may not exist already, but we are deleting, so it doesn't much matter.
			var request:URLVariables = makeRequest("reset");
			if (request)
			{
				request.id = quest.id;
				sendRequest(request);
			}
		}
		private function requestReturn(e:ManagerEvent):void
		{
			var vars:URLVariables = new URLVariables(e.data);
			if (vars.Action == "available")
			{
				//Find quest by ID
				for each (var quest:Quest in questLibrary)
				{
					if (quest.id == -vars.RequestID)
					{
						quest.setID(vars.NewID);
						break;
					}
				}
			}
		}
		
		
		//**********************************************************************
		//
		//                         NORMAL FUNCTIONS
		//
		//**********************************************************************
		public function makeQuestAvailable(questId:uint, sendRequest:Boolean=true):void
		{
			if (questLibrary[questId] == undefined)
			{
				Cc.error("Undefined questId in Quest Library: " + questId);
				return;
			}
			var quest:Quest = questLibrary[questId];
			if (quest.state != Quest.QUESTSTATE_NONE)
			{
				Cc.warn("Quest " + quest.id + " \"" + quest.name + "\" already available, started, or finished");
				return;
			}
				
			_questsAvailable.push(questId);
			
			quest.setState(Quest.QUESTSTATE_AVAILABLE);
			dispatchEvent(new QuestEvent(QuestEvent.QUEST_BECAMEAVAILABLE, quest, questId));
			sendQuestAvailableRequest(quest);
			Cc.info("Quest " + quest.id + " \"" + quest.name + "\" available");
		}
		public function startQuest(questId:uint):void
		{
			if (questLibrary[questId] == undefined)
			{
				Cc.error("Undefined questId in Quest Library: " + questId);
				return;
			}
			var quest:Quest = questLibrary[questId];
			if (quest.state != Quest.QUESTSTATE_AVAILABLE)
			{
				Cc.warn("Quest " + quest.id + " \"" + quest.name + "\" already started");
				return;
			}
			
			_questsAvailable.splice(_questsAvailable.indexOf(questId), 1);
			_questsToUpdate.push(questId);
			
			quest.setState(Quest.QUESTSTATE_STARTED);
			quest.start();
			dispatchEvent(new QuestEvent(QuestEvent.QUEST_STARTED, quest, questId));
			sendQuestStartedEvent(quest);
			Cc.info("Quest " + quest.id + " \"" + quest.name + "\" started");
		}
		public function updateQuest(questId:uint, value:*=null):void
		{
			if (questLibrary[questId] == undefined)
			{
				Cc.error("Undefined questId in Quest Library: " + questId);
				return;
			}
			var quest:Quest = questLibrary[questId];
			if (!quest.state == Quest.QUESTSTATE_STARTED)
			{
				Cc.warn("Quest " + quest.id + " \"" + quest.name + "\" can not be updated");
				return;
			}
			
			quest.updateValue(value);
			sendQuestUpdateRequest(quest);
		}
		public function resetQuest(questId:uint):void
		{
			if (questLibrary[questId] == undefined)
			{
				Cc.error("Undefined questid in Quest Library: " + questId);
				return;
			}
			
			//Quest values
			var quest:Quest = questLibrary[questId];
			quest.setState(Quest.QUESTSTATE_NONE);
			quest.setShouldUpdateServer(false);
			quest.reset();
			
			//Remove from arrays
			var idx:Number = _questsAvailable.indexOf(questId);
			if (idx != -1)
				_questsAvailable.splice(idx, 1);
			idx = _questsToUpdate.indexOf(questId);
			if (idx != -1)
				_questsToUpdate.splice(idx, 1);
			idx = _questsComplete.indexOf(questId);
			if (idx != -1)
				_questsComplete.splice(idx, 1);
			
			//Server
			sendQuestResetRequest(quest);
		}
		
		
		public function update():void
		{
			var removeQuests:Array = [];
			//Update quests
			for each (var questId:uint in _questsToUpdate)
			{
				var quest:Quest = questLibrary[questId];
				var questComplete:Boolean = quest.update();
				//After an update, but before "finishing" a quest, we may need to update the server on the quest's progress
				if (quest.shouldUpdateServer)
				{
					sendQuestUpdateRequest(quest);
					quest.setShouldUpdateServer(false);
				}
				//Now we can finish the quest if required
				if (questComplete)
				{
					//Assign rewards first as some rely on checking stuff that's set for the quest
					for each (var reward:Reward in quest.rewards)
						reward.apply(questId);
					
					MinionManager.instance.clearQuestIdFromMinions(questId);
						
					quest.setState(Quest.QUESTSTATE_FINISHED);
					removeQuests.push(questId);
					_questsComplete.push(questId);
					
					dispatchEvent(new QuestEvent(QuestEvent.QUEST_COMPLETE, quest, questId));
					sendQuestFinishedEvent(quest);
					Cc.info("Quest " + quest.id + " \"" + quest.name + "\" complete");
				}
				else if (quest.updatePending)
					//If we didn't finish the quest before, maybe the quest has a value update to share
					dispatchEvent(new QuestEvent(QuestEvent.QUEST_UPDATED, quest, questId));
			}
			//Cleanup completed quests
			for each (var removeQuestId:uint in removeQuests)
			{
				_questsToUpdate.splice(_questsToUpdate.indexOf(removeQuestId), 1);
			}
		}
	}

}