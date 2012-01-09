package
{
	import com.cinder.common.config.Configuration;
	import com.junkbyte.console.Cc;
	import managers.city.CityEvent;
	import managers.CityManager;
	import managers.ManagerEvent;
	import managers.MinionManager;
	import managers.minions.MinionEvent;
	import managers.QuestManager;
	import managers.quests.QuestEvent;
	import managers.ResourceManager;
	import managers.resources.ResourceEvent;
	import org.flixel.FlxG;
	import org.flixel.FlxState;
	import org.flixel.FlxText;
	
	
	public class StreamState extends FlxState
	{
		//Loaded flags
		private var _resourceCount:int = 0;
		private var _resourceCurrent:int = 0;
		private var _resources:Boolean = false;
		
		private var _buildingCount:int = 0;
		private var _buildingCurrent:int = 0;
		private var _buildings:Boolean = false;
		
		private var _questCount:int = 0;
		private var _questCurrent:int = 0;
		private var _quests:Boolean = false;
		
		private var _minionCount:int = 0;
		private var _minionCurrent:int = 0;
		private var _minions:Boolean = false;
		
		
		override public function create():void
		{
			Cc.log("*****Stream State*****");
			FlxG.bgColor = 0xff1105ef;
			FlxG.mouse.show();
			
			//Send request for saved resources
			ResourceManager.instance.addEventListener(ResourceEvent.RESOURCE_AMOUNTCHANGED, resourceLoaded);
			ResourceManager.instance.addEventListener(ManagerEvent.MANAGER_SERVERLOADSTART, resourceLoadStart);
			ResourceManager.instance.addEventListener(ManagerEvent.MANAGER_SERVERLOADEND, resourceLoadEnd);
			ResourceManager.instance.addEventListener(ManagerEvent.MANAGER_SERVERERROR, resourceServerError);
			ResourceManager.instance.loadDataFromServer();
			
			//Send request for saved buildings
			CityManager.instance.addEventListener(CityEvent.CITY_BUILDING_PLACED, buildingLoaded);
			CityManager.instance.addEventListener(ManagerEvent.MANAGER_SERVERLOADSTART, cityServerLoadStart);
			CityManager.instance.addEventListener(ManagerEvent.MANAGER_SERVERLOADEND, cityServerLoadEnd);
			CityManager.instance.addEventListener(ManagerEvent.MANAGER_SERVERERROR, cityServerError);
			CityManager.instance.loadDataFromServer();
			
			//Send request for saved quests
			QuestManager.instance.addEventListener(QuestEvent.QUEST_BECAMEAVAILABLE, questAvailable);
			QuestManager.instance.addEventListener(QuestEvent.QUEST_STARTED, questStarted);
			QuestManager.instance.addEventListener(QuestEvent.QUEST_COMPLETE, questCompleted);
			QuestManager.instance.addEventListener(ManagerEvent.MANAGER_SERVERLOADSTART, questServerLoadStart);
			QuestManager.instance.addEventListener(ManagerEvent.MANAGER_SERVERLOADEND, questServerLoadEnd);
			QuestManager.instance.addEventListener(ManagerEvent.MANAGER_SERVERERROR, questServerError);
			QuestManager.instance.loadDataFromServer();
			
			//Send request for saved minions
			MinionManager.instance.addEventListener(MinionEvent.MINION_ADDED, minionLoaded);
			MinionManager.instance.addEventListener(ManagerEvent.MANAGER_SERVERLOADSTART, minionServerLoadStart);
			MinionManager.instance.addEventListener(ManagerEvent.MANAGER_SERVERLOADEND, minionServerLoadEnd);
			MinionManager.instance.addEventListener(ManagerEvent.MANAGER_SERVERERROR, minionServerError);
			MinionManager.instance.loadDataFromServer();
		}
		
		private function resourceLoadStart(e:ManagerEvent):void 
		{
			Cc.info(e.data + " resources to read");
			_resourceCount = new Number(e.data);
		}
		private function resourceLoadEnd(e:ManagerEvent):void 
		{
			_resources = true;
			checkCompletion();
		}
		private function resourceLoaded(e:ResourceEvent):void 
		{
			++_resourceCurrent;
			Cc.info("(" + _resourceCurrent.toString() + "/" + _resourceCount.toString() + ") " + ResourceManager.getResourceName(e.resource) + ": " + ResourceManager.instance.getResource(e.resource));
		}
		private function resourceServerError(e:ManagerEvent):void 
		{
			Cc.error("Server error while retrieving resources");
			cleanup();
		}
		
		private function buildingLoaded(e:CityEvent):void 
		{
			Cc.info("Placing "  + e.building.name);
			++_buildingCurrent;
		}
		private function cityServerLoadStart(e:ManagerEvent):void 
		{
			Cc.info(e.data + " buildings to place");
			_buildingCount = new Number(e.data);
		}
		private function cityServerLoadEnd(e:ManagerEvent):void 
		{
			_buildings = true;
			checkCompletion();
		}
		private function cityServerError(e:ManagerEvent):void 
		{
			Cc.error("Server error while retrieving buildings");
			cleanup();
		}
		
		private function questAvailable(e:QuestEvent):void
		{
			Cc.info("Quest " + e.quest.id + " \"" + e.quest.name + "\" is available");
			++_questCurrent;
		}
		private function questStarted(e:QuestEvent):void
		{
			Cc.info("Quest " + e.quest.id + " \"" + e.quest.name + "\" is started");
			++_questCurrent;
		}
		private function questCompleted(e:QuestEvent):void
		{
			Cc.info("Quest " + e.quest.id + " \"" + e.quest.name + "\" is finished");
			++_questCurrent;
		}
		private function questServerLoadStart(e:ManagerEvent):void
		{
			Cc.info(e.data + " quests to initialize");
			_questCount = new Number(e.data);
		}
		private function questServerLoadEnd(e:ManagerEvent):void
		{
			_quests = true;
			checkCompletion();
		}
		private function questServerError(e:ManagerEvent):void
		{
			Cc.error("Server error while retrieving quests");
			cleanup();
		}
		
		private function minionLoaded(e:MinionEvent):void 
		{
			Cc.info("Minion " + e.minion.id + " \"" + e.minion.name + "\" loaded");
			++_minionCurrent;
		}
		private function minionServerLoadStart(e:ManagerEvent):void 
		{
			Cc.info(e.data + " minions to initialize");
			_minionCount = new Number(e.data);
		}
		private function minionServerLoadEnd(e:ManagerEvent):void 
		{
			_minions = true;
			checkCompletion();
		}
		private function minionServerError(e:ManagerEvent):void 
		{
			Cc.error("Server error while retrieving minions");
			cleanup();
		}
		
		
		private function checkCompletion():void
		{
			if (_resources &&
				_buildings &&
				_quests)
			{
				cleanup();
				FlxG.switchState(new PlayState);
			}
		}
		private function cleanup():void
		{
			ResourceManager.instance.removeEventListener(ResourceEvent.RESOURCE_AMOUNTCHANGED, resourceLoaded);
			ResourceManager.instance.removeEventListener(ManagerEvent.MANAGER_SERVERLOADSTART, resourceLoadStart);
			ResourceManager.instance.removeEventListener(ManagerEvent.MANAGER_SERVERLOADEND, resourceLoadEnd);
			ResourceManager.instance.removeEventListener(ManagerEvent.MANAGER_SERVERERROR, resourceServerError);
			
			CityManager.instance.removeEventListener(CityEvent.CITY_BUILDING_PLACED, buildingLoaded);
			CityManager.instance.removeEventListener(ManagerEvent.MANAGER_SERVERLOADSTART, cityServerLoadStart);
			CityManager.instance.removeEventListener(ManagerEvent.MANAGER_SERVERLOADEND, cityServerLoadEnd);
			CityManager.instance.removeEventListener(ManagerEvent.MANAGER_SERVERERROR, cityServerError);
			
			QuestManager.instance.removeEventListener(QuestEvent.QUEST_BECAMEAVAILABLE, questAvailable);
			QuestManager.instance.removeEventListener(QuestEvent.QUEST_STARTED, questStarted);
			QuestManager.instance.removeEventListener(QuestEvent.QUEST_COMPLETE, questCompleted);
			QuestManager.instance.removeEventListener(ManagerEvent.MANAGER_SERVERLOADSTART, questServerLoadStart);
			QuestManager.instance.removeEventListener(ManagerEvent.MANAGER_SERVERLOADEND, questServerLoadEnd);
			QuestManager.instance.removeEventListener(ManagerEvent.MANAGER_SERVERERROR, questServerError);
			
			MinionManager.instance.removeEventListener(MinionEvent.MINION_ADDED, minionLoaded);
			MinionManager.instance.removeEventListener(ManagerEvent.MANAGER_SERVERLOADSTART, minionServerLoadStart);
			MinionManager.instance.removeEventListener(ManagerEvent.MANAGER_SERVERLOADEND, minionServerLoadEnd);
			MinionManager.instance.removeEventListener(ManagerEvent.MANAGER_SERVERERROR, minionServerError);
		}
	}
}

