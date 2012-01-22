package managers 
{
	import com.cinder.common.ui.FlxPopup;
	import com.cinder.common.ui.PopupEvent;
	import com.junkbyte.console.Cc;
	import managers.city.buildings.Building_Barracks;
	import managers.city.buildings.Building_Farm;
	import managers.city.buildings.Building_Quarters;
	import managers.city.CityEvent;
	import managers.minions.Minion;
	import managers.minions.MinionEvent;
	import managers.quests.Quest;
	import managers.quests.QuestEvent;
	import org.flixel.FlxG;
	/**
	 * ...
	 * @author Jed Lang
	 */
	public class QuestWatcher
	{
		//Singleton
		private static var _instance:QuestWatcher;
		public static function get instance():QuestWatcher
		{
			if (!_instance)
				_instance = new QuestWatcher();
			return _instance;
		}
		
		
		private var _initialized:Boolean = false;
		private var _startedQuestIds:Array;
		
		
		public function QuestWatcher() 
		{
			_startedQuestIds = [];
			QuestManager.instance.addEventListener(QuestEvent.QUEST_STARTED, quest_started);
			QuestManager.instance.addEventListener(QuestEvent.QUEST_COMPLETE, quest_completed);
			QuestManager.instance.addEventListener(ManagerEvent.MANAGER_ITEMIDUPDATED, quest_idUpdated);
		}
		public function init():void
		{
			if (_initialized)
				return;
			_initialized = true;
			
			//Watch everything that's required by ANY quests
			//More events will be watched as more variety of quests get created
			CityManager.instance.addEventListener(CityEvent.CITY_BUILDING_PLACED, city_buildingPlaced);
			MinionManager.instance.addEventListener(MinionEvent.MINION_ADDED, minion_added);
		}
		
		
		//*********************************************************
		//
		//                      LISTENERS
		//
		//*********************************************************
		private function quest_started(e:QuestEvent):void
		{
			_startedQuestIds.push(e.questId);
		}
		private function quest_completed(e:QuestEvent):void
		{
			_startedQuestIds.splice(_startedQuestIds.indexOf(e.questId), 1);
			MinionManager.instance.clearQuestIdFromMinions(e.questId);
			
			//Show final text
			if (e.quest.completeText != "")
			{
				var popup:FlxPopup = new FlxPopup(true, Pilot.POPUPIMG_PNG, e.quest.completeText, "Quest Complete!", 160, 120, 350, 175);
				popup.addEventListener(PopupEvent.POPUP_CLICK, popup_Click);
				FlxG.state.add(popup);
			}
		}
		private function popup_Click(e:PopupEvent):void
		{
			FlxG.state.remove(e.popup);
		}
		private function quest_idUpdated(e:ManagerEvent):void
		{
			var vals:Array = e.data.split(":");
			var oldId:Number = Number(vals[0]);
			var newId:Number = Number(vals[1]);
			
			for (var i:Number = 0; i < MinionManager.instance.minionCount; ++i)
			{
				var minion:Minion = MinionManager.instance.getMinionByIndex(i);
				if (minion.questId == oldId)
					minion.questId = newId;
			}
		}
		
		private function city_buildingPlaced(e:CityEvent):void
		{
			for each(var questId:Number in _startedQuestIds)
			{
				switch (questId)
				{
					case QuestManager.QUEST_MINIONHOUSING1:
						{
							if (e.building is Building_Quarters)
								QuestManager.instance.updateQuest(questId);	//1 step, so will complete
							break;
						}
					case QuestManager.QUEST_BARRACKS1:
						{
							if (e.building is Building_Barracks)
								QuestManager.instance.updateQuest(questId);	//1 step, so will complete
							break;
						}
					case QuestManager.QUEST_FARM1:
						{
							if (e.building is Building_Farm)
								QuestManager.instance.updateQuest(questId);	//1 step, so will complete
							break;
						}
				}
			}
		}
		private function minion_added(e:MinionEvent):void
		{
			for each (var questId:Number in _startedQuestIds)
			{
				switch (questId)
				{
					case QuestManager.QUEST_ACQUIREMINION1:
						{
							QuestManager.instance.updateQuest(questId);	//1 step, so will complete
							break;
						}
				}
			}
		}
	}

}