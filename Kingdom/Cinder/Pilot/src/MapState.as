package
{
	import com.cinder.common.ui.FlxPopup;
	import com.junkbyte.console.Cc;
	import flash.events.Event;
	import flash.utils.Dictionary;
	import managers.MinionManager;
	import managers.minions.Minion;
	import managers.minions.MinionBuilder;
	import managers.minions.MinionEvent;
	import managers.QuestManager;
	import managers.quests.GametimeQuest;
	import managers.quests.Quest;
	import managers.quests.QuestEvent;
	import managers.quests.RealtimeQuest;
	import managers.quests.StepQuest;
	import org.flixel.FlxButton;
	import org.flixel.FlxG;
	import org.flixel.FlxState;
	import org.flixel.FlxText;
	import org.flixel.FlxU;
	import states.FlxButtonTag;
	import states.map.FlxQuestButton;
	import states.MinionSelector;
	
	public class MapState extends FlxState
	{
		private var _questButtons:Dictionary;
		
		private var _questInfoPopup:FlxPopup;
		private var _preQuestDisplay:MinionSelector;
		
		private var _cityButton:FlxButton;
		
		private var _NonLocationQuestXOffset:Number = 10;
		private var _NonLocationQuestYOffset:Number = 50;
		
		
		override public function create():void
		{
			Cc.log("*****Map State*****");
			FlxG.bgColor = 0xff313210;
			
			_questButtons = new Dictionary();
			
			//Watch for quest changes as we need to update the display
			QuestManager.instance.addEventListener(QuestEvent.QUEST_BECAMEAVAILABLE, quest_Available);
			QuestManager.instance.addEventListener(QuestEvent.QUEST_STARTED, quest_Started);
			QuestManager.instance.addEventListener(QuestEvent.QUEST_UPDATED, quest_Updated);
			QuestManager.instance.addEventListener(QuestEvent.QUEST_COMPLETE, quest_Complete);
			
			//Quest buttons
			for each (var quest:Quest in QuestManager.questLibrary)
			{
				if (quest.state == Quest.QUESTSTATE_AVAILABLE ||
					quest.state == Quest.QUESTSTATE_STARTED)
				{
					var button:FlxQuestButton = generateButtonForQuest(quest);
					_questButtons[quest.questId] = button;
					add(button);
				}
			}
			
			//City button
			_cityButton = new FlxButton(0, FlxG.height - 20, "City", city_Click);
			add(_cityButton);
		}
		private function generateButtonForQuest(quest:Quest):FlxQuestButton
		{
			var actualX:Number = quest.x;
			var actualY:Number = quest.y;
			if (quest.x == -1 &&
				quest.y == -1)
			{
				//Special case: None-location based
				actualX = _NonLocationQuestXOffset;
				actualY = _NonLocationQuestYOffset;
				while (true)
				{
					var match:Boolean = false;
					for each (var button:FlxQuestButton in _questButtons)
					{
						if (button.y == actualY)
						{
							match = true;
							break;
						}
					}
					if (match)
						actualY += 20;
					else
						break;
				}
			}
			var ret:FlxQuestButton = new FlxQuestButton(actualX, actualY, quest.name, questButton_Click, quest.questId);
			ret.maxValue = quest.state == Quest.QUESTSTATE_STARTED ? quest.valueGoal : 1;
			ret.currentvalue = quest.state == Quest.QUESTSTATE_STARTED ? quest.valueCurrent : 0;
			return ret;
		}
		override public function destroy():void 
		{
			QuestManager.instance.removeEventListener(QuestEvent.QUEST_BECAMEAVAILABLE, quest_Available);
			QuestManager.instance.removeEventListener(QuestEvent.QUEST_STARTED, quest_Started);
			QuestManager.instance.removeEventListener(QuestEvent.QUEST_UPDATED, quest_Updated);
			QuestManager.instance.removeEventListener(QuestEvent.QUEST_COMPLETE, quest_Complete);
			super.destroy();
		}
		
		
		private function quest_Available(e:QuestEvent):void
		{
			if (e.quest.repeatable)
			{
				if (_questButtons[e.questId] != undefined)
				{
					var questButton:FlxQuestButton = _questButtons[e.questId];
					questButton.currentvalue = 0;
				}
			}
			else
			{
				var button:FlxQuestButton = generateButtonForQuest(e.quest);
				_questButtons[e.questId] = button;
				add(button);
			}
		}
		private function quest_Started(e:QuestEvent):void
		{
			if (_questButtons[e.questId] != undefined)
			{
				var questButton:FlxQuestButton = _questButtons[e.questId];
				questButton.maxValue = e.quest.valueGoal ? e.quest.valueGoal : 1;
			}
		}
		private function quest_Updated(e:QuestEvent):void
		{
			if (_questButtons[e.questId] != undefined)
			{
				var questButton:FlxQuestButton = _questButtons[e.questId];
				questButton.currentvalue = e.quest.valueCurrent;
			}
		}
		private function quest_Complete(e:QuestEvent):void
		{
			if (_questButtons[e.questId] != undefined)
			{
				if (!e.quest.repeatable)
				{
					remove(_questButtons[e.questId]);
					_questButtons[e.questId] = undefined;
				}
			}
		}
		
		
		//*********************************************************
		//
		//                 BUTTON CLICK HANDLERS
		//
		//*********************************************************
		private function city_Click():void
		{
			FlxG.switchState(new PlayState);
		}
		private function questButton_Click(tag:*):void 
		{
			if (tag is uint)
			{
				var quest:Quest = QuestManager.questLibrary[tag as uint];
				if (!quest.requiredStats ||
					quest.state == Quest.QUESTSTATE_STARTED)
				{
					hideQuestInfoPopup();
					showQuestInfoPopup(tag as uint);
				}
				else
				{
					removePreQuestDisplay();
					addPreQuestDisplay(tag as uint);
				}
			}
		}
		private function showQuestInfoPopup(questId:Number):void
		{
			removePreQuestDisplay();
			var quest:Quest = QuestManager.questLibrary[questId];
			_questInfoPopup = new FlxPopup(true, Pilot.POPUPIMG_PNG, quest.description, quest.name, FlxG.width / 2 - 100, FlxG.height / 2 - 100, 200, 200);
			add(_questInfoPopup);
			
			Cc.log("Created QuestInfoPopup for \"" + quest.name + "\"");
		}
		private function hideQuestInfoPopup():void
		{
			if (_questInfoPopup)
			{
				remove(_questInfoPopup);
				_questInfoPopup.destroy();
				_questInfoPopup = null;
			}
		}
		private function addPreQuestDisplay(questId:Number):void
		{
			hideQuestInfoPopup();
			var quest:Quest = QuestManager.questLibrary[questId];
			_preQuestDisplay = new MinionSelector(quest.name, quest.description, questId,
				quest.requiredStats.fighterStat, quest.requiredStats.mageStat, quest.requiredStats.gathererStat, quest.requiredStats.builderStat);
			_preQuestDisplay.addEventListener(MinionSelector.MINIONSELECTOR_OK, preQuestOk_Click);
			_preQuestDisplay.addEventListener(MinionSelector.MINIONSELECTOR_CANCEL, preQuestCancel_Click);
			add(_preQuestDisplay);
			
			Cc.log("Created PreQuestDisplay for \"" + quest.name + "\"");
		}
		private function removePreQuestDisplay():void
		{
			if (_preQuestDisplay)
			{
				remove(_preQuestDisplay);
				_preQuestDisplay.removeEventListener(MinionSelector.MINIONSELECTOR_OK, preQuestOk_Click);
				_preQuestDisplay.removeEventListener(MinionSelector.MINIONSELECTOR_CANCEL, preQuestCancel_Click);
				_preQuestDisplay.destroy();
				_preQuestDisplay = null;
			}
		}
		private function preQuestOk_Click(e:Event):void
		{
			var minion:Minion = MinionManager.instance.getMinionByIndex(_preQuestDisplay.showingMinionIndex);
			MinionManager.instance.assignQuestToMinion(minion, _preQuestDisplay.userData as Number);
			QuestManager.instance.startQuest(_preQuestDisplay.userData as Number);
			removePreQuestDisplay();
		}
		private function preQuestCancel_Click(e:Event):void
		{
			removePreQuestDisplay();
		}
	}
}

