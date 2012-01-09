package
{
	import com.junkbyte.console.Cc;
	import flash.events.Event;
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
	import states.map.PreQuestDisplay;
	
	public class MapState extends FlxState
	{
		private var _preQuestDisplay:PreQuestDisplay;
		
		//Quests
//		private var _testRealtimeButton:FlxButton;	private var _realtimeButton:FlxButton;	private var _realtimeOutput:FlxText;
//		private var _testGametimeButton:FlxButton;	private var _gametimeButton:FlxButton;	private var _gametimeOutput:FlxText;
//		private var _testStepButton:FlxButton;		private var _stepButton:FlxButton;		private var _stepOutput:FlxText;
		
		private var _resetButton:FlxButton;
		
		//Minions
		private var _minionsTotalCount:FlxText;
		private var _minionsOnQuestsCount:FlxText;
		private var _addGenericMinionButton:FlxButton;
		private var _addFighterMinionButton:FlxButton;
		private var _addMageMinionButton:FlxButton;
		private var _addGathererMinionButton:FlxButton;
		private var _addBuilderMinionButton:FlxButton;
		
		
		override public function create():void
		{
			Cc.log("*****Map State*****");
			FlxG.bgColor = 0xff313210;
			
			//Quest buttons
			//TODO: Properly implement
			for each (var quest:Quest in QuestManager.questLibrary)
			{
				var button:FlxButtonTag = new FlxButtonTag(quest.x, quest.y, quest.name, questButton_Click, quest);
				button.visible = false;
				add(button);
			}
			
			QuestManager.instance.addEventListener(QuestEvent.QUEST_BECAMEAVAILABLE, questAvailable_Handler);
			QuestManager.instance.addEventListener(QuestEvent.QUEST_STARTED, questStarted_Handler);
			QuestManager.instance.addEventListener(QuestEvent.QUEST_UPDATED, questUpdate_Handler);
			QuestManager.instance.addEventListener(QuestEvent.QUEST_COMPLETE, questComplete_Handler);
			
			
			//Quests Testing
//			var realtimeQuest:Quest = QuestManager.questLibrary[QuestManager.QUEST_TIMEDTEST1];
//			_testRealtimeButton = new FlxButton(realtimeQuest.x - 80, realtimeQuest.y, "Enable Real", enableRealTimeQuest_Handler);
//			add(_testRealtimeButton);
//			_realtimeButton = new FlxButtonTag(realtimeQuest.x, realtimeQuest.y, "Realtime 30", questButton_Click, QuestManager.QUEST_TIMEDTEST1);
//			add(_realtimeButton);
//			_realtimeOutput = new FlxText(realtimeQuest.x + 80, realtimeQuest.y, 100);
//			add(_realtimeOutput);
			
//			var gametimeQuest:Quest = QuestManager.questLibrary[QuestManager.QUEST_TIMEDTEST2];
//			_testGametimeButton = new FlxButton(gametimeQuest.x - 80, gametimeQuest.y, "Enable Game", enableGameTimeQuest_Handler);
//			add(_testGametimeButton);
//			_gametimeButton = new FlxButtonTag(gametimeQuest.x, gametimeQuest.y, "Gametime 5", questButton_Click, QuestManager.QUEST_TIMEDTEST2);
//			add(_gametimeButton);
//			_gametimeOutput = new FlxText(gametimeQuest.x + 80, gametimeQuest.y, 100);
//			add(_gametimeOutput);
			
//			var stepQuest:Quest = QuestManager.questLibrary[QuestManager.QUEST_STEPTEST];
//			_testStepButton = new FlxButton(stepQuest.x - 80, stepQuest.y, "Enable Step", enableStepQuest_Handler);
//			add(_testStepButton);
//			_stepButton = new FlxButtonTag(stepQuest.x, stepQuest.y, "Step 5", stepQuestButton_Click, QuestManager.QUEST_STEPTEST);
//			add(_stepButton);
//			_stepOutput = new FlxText(stepQuest.x + 80, stepQuest.y, 100);
//			add(_stepOutput);
			
//			setTestButtonVisibilitiesAndOutputs();
//			_resetButton = new FlxButton(FlxG.width - 80, 0, "Reset All", resetButton_Click);
//			add(_resetButton);
			
			
			//Minions Testing
			MinionManager.instance.addEventListener(MinionEvent.MINION_ADDED, minionAdded_Handler);
			MinionManager.instance.addEventListener(MinionEvent.MINION_REMOVED, minionRemoved_Handler);
			
			
			_minionsTotalCount = new FlxText(0, FlxG.height - 40, 150);
			add(_minionsTotalCount);
			_minionsOnQuestsCount = new FlxText(0, FlxG.height - 20, 150);
			add(_minionsOnQuestsCount);
			
			_addGenericMinionButton = new FlxButton(0, FlxG.height - 140, "Add Generic", addGenericMinion_Click);
			add(_addGenericMinionButton);
			_addFighterMinionButton = new FlxButton(0, FlxG.height - 120, "Add Fighter", addFighterMinion_Click);
			add(_addFighterMinionButton);
			_addMageMinionButton = new FlxButton(0, FlxG.height - 100, "Add Mage", addMageMinion_Click);
			add(_addMageMinionButton);
			_addGathererMinionButton = new FlxButton(0, FlxG.height - 80, "Add Gatherer", addGathererMinion_Click);
			add(_addGathererMinionButton);
			_addBuilderMinionButton = new FlxButton(0, FlxG.height - 60, "Add Builder", addBuilderMinion_Click);
			add(_addBuilderMinionButton);
			recalculateMinionCounts();
		}
		private function setTestButtonVisibilitiesAndOutputs():void 
		{
//			var realtimeQuest:Quest = QuestManager.questLibrary[QuestManager.QUEST_TIMEDTEST1];
//			switch (realtimeQuest.state)
//			{
//				case Quest.QUESTSTATE_NONE:
//					{
//						_testRealtimeButton.visible = true;
//						_realtimeButton.visible = false;
//						_realtimeOutput.text = "";
//						break;
//					}
//				case Quest.QUESTSTATE_AVAILABLE:
//					{
//						_testRealtimeButton.visible = false;
//						_realtimeButton.visible = true;
//						_realtimeOutput.text = "";
//						break;
//					}
//				case Quest.QUESTSTATE_STARTED:
//					{
//						_testRealtimeButton.visible = false;
//						_realtimeButton.visible = false;
//						_realtimeOutput.text = (realtimeQuest.percentDone * 100).toFixed() + "%";
//						break;
//					}
//				case Quest.QUESTSTATE_FINISHED:
//					{
//						_testRealtimeButton.visible = false;
//						_realtimeButton.visible = false;
//						_realtimeOutput.text = "Complete!";
//						break;
//					}
//			}
//			var gametimeQuest:Quest = QuestManager.questLibrary[QuestManager.QUEST_TIMEDTEST2];
//			switch (gametimeQuest.state)
//			{
//				case Quest.QUESTSTATE_NONE:
//					{
//						_testGametimeButton.visible = true;
//						_gametimeButton.visible = false;
//						_gametimeOutput.text = "";
//						break;
//					}
//				case Quest.QUESTSTATE_AVAILABLE:
//					{
//						_testGametimeButton.visible = false;
//						_gametimeButton.visible = true;
//						_gametimeOutput.text = "";
//						break;
//					}
//				case Quest.QUESTSTATE_STARTED:
//					{
//						_testGametimeButton.visible = false;
//						_gametimeButton.visible = false;
//						_gametimeOutput.text = (gametimeQuest.percentDone * 100).toFixed() + "%";
//						break;
//					}
//				case Quest.QUESTSTATE_FINISHED:
//					{
//						_testGametimeButton.visible = false;
//						_gametimeButton.visible = false;
//						_gametimeOutput.text = "Complete!";
//						break;
//					}
//			}
//			var stepQuest:Quest = QuestManager.questLibrary[QuestManager.QUEST_STEPTEST];
//			switch (stepQuest.state)
//			{
//				case Quest.QUESTSTATE_NONE:
//					{
//						_testStepButton.visible = true;
//						_stepButton.visible = false;
//						_stepOutput.text = "";
//						break;
//					}
//				case Quest.QUESTSTATE_AVAILABLE:
//					{
//						_testStepButton.visible = false;
//						_stepButton.visible = true;
//						_stepOutput.text = "";
//						break;
//					}
//				case Quest.QUESTSTATE_STARTED:
//					{
//						_testStepButton.visible = false;
//						_stepButton.visible = true;
//						_stepOutput.text = (stepQuest.percentDone * 100).toFixed() + "%";
//						break;
//					}
//				case Quest.QUESTSTATE_FINISHED:
//					{
//						_testStepButton.visible = false;
//						_stepButton.visible = false;
//						_stepOutput.text = "Complete!";
//						break;
//					}
//			}
		}
		
		
		//*********************************************************
		//
		//                 BUTTON CLICK HANDLERS
		//
		//*********************************************************
		private function enableRealTimeQuest_Handler():void 
		{
//			QuestManager.instance.makeQuestAvailable(QuestManager.QUEST_TIMEDTEST1);
			setTestButtonVisibilitiesAndOutputs();
		}
		private function enableGameTimeQuest_Handler():void 
		{
//			QuestManager.instance.makeQuestAvailable(QuestManager.QUEST_TIMEDTEST2);
			setTestButtonVisibilitiesAndOutputs();
		}
		private function enableStepQuest_Handler():void 
		{
//			QuestManager.instance.makeQuestAvailable(QuestManager.QUEST_STEPTEST);
			setTestButtonVisibilitiesAndOutputs();
		}
		private function questButton_Click(tag:*):void 
		{
			if (tag is uint)
				QuestManager.instance.startQuest(tag as uint);
			setTestButtonVisibilitiesAndOutputs();
		}
		private function stepQuestButton_Click(tag:*):void
		{
			if (tag is uint)
			{
				if (QuestManager.questLibrary[tag].state == Quest.QUESTSTATE_STARTED)
					QuestManager.instance.updateQuest(tag as uint);
				else
				{
					removePreQuestDisplay();
					addPreQuestDisplay(tag as uint);
				}
			}
			setTestButtonVisibilitiesAndOutputs();
		}
		private function addPreQuestDisplay(questId:Number):void
		{
			_preQuestDisplay = new PreQuestDisplay(questId);
			_preQuestDisplay.addEventListener(PreQuestDisplay.QUESTDISPLAY_OK, preQuestOk_Click);
			_preQuestDisplay.addEventListener(PreQuestDisplay.QUESTDISPLAY_CANCEL, preQuestCancel_Click);
			add(_preQuestDisplay);
			
			var quest:Quest = QuestManager.questLibrary[questId];
			Cc.log("Created PreQuestDisplay for \"" + quest.name + "\"");
		}
		private function removePreQuestDisplay():void
		{
			if (_preQuestDisplay)
			{
				remove(_preQuestDisplay);
				_preQuestDisplay.removeEventListener(PreQuestDisplay.QUESTDISPLAY_OK, preQuestOk_Click);
				_preQuestDisplay.removeEventListener(PreQuestDisplay.QUESTDISPLAY_CANCEL, preQuestCancel_Click);
				_preQuestDisplay.destroy();
				_preQuestDisplay = null;
			}
		}
		private function resetButton_Click():void
		{
//			QuestManager.instance.resetQuest(QuestManager.QUEST_TIMEDTEST1);
//			QuestManager.instance.resetQuest(QuestManager.QUEST_TIMEDTEST2);
//			QuestManager.instance.resetQuest(QuestManager.QUEST_STEPTEST);
			
			//Reset UI
			setTestButtonVisibilitiesAndOutputs();
		}
		private function preQuestOk_Click(e:Event):void
		{
			QuestManager.instance.startQuest(_preQuestDisplay.questId);
			removePreQuestDisplay();
			recalculateMinionCounts();
		}
		private function preQuestCancel_Click(e:Event):void
		{
			removePreQuestDisplay();
			recalculateMinionCounts();
		}
		
		private function addGenericMinion_Click():void
		{
			MinionManager.instance.addNewMinion("Generic Name", MinionManager.getRandomMinionSex());
		}
		private function addFighterMinion_Click():void
		{
			var builder:MinionBuilder = new MinionBuilder();
			builder.fighterStat = 5;
			MinionManager.instance.addNewMinion("Fighter Name", MinionManager.getRandomMinionSex(), builder);
		}
		private function addMageMinion_Click():void
		{
			var builder:MinionBuilder = new MinionBuilder();
			builder.mageStat = 5;
			MinionManager.instance.addNewMinion("Mage Name", MinionManager.getRandomMinionSex(), builder);
		}
		private function addGathererMinion_Click():void
		{
			var builder:MinionBuilder = new MinionBuilder();
			builder.gathererStat = 5;
			MinionManager.instance.addNewMinion("Gatherer Name", MinionManager.getRandomMinionSex(), builder);
		}
		private function addBuilderMinion_Click():void
		{
			var builder:MinionBuilder = new MinionBuilder();
			builder.builderStat = 5;
			MinionManager.instance.addNewMinion("Builder Name", MinionManager.getRandomMinionSex(), builder);
		}
		
		
		//*********************************************************
		//
		//                 QUEST EVENT HANDLERS
		//
		//*********************************************************
		private function questAvailable_Handler(e:QuestEvent):void 
		{
			for each (var o:* in members)
			{
				if (o is FlxButtonTag)
				{
					var button:FlxButtonTag = o as FlxButtonTag;
					if (button.tag is uint)
					{
						var questId:uint = button.tag as uint;
						if (e.questId == questId)
						{
							button.visible = true;
							break;
						}
					}
				}
			}
		}
		private function questStarted_Handler(e:QuestEvent):void
		{
//			if (e.quest is RealtimeQuest)
//				_realtimeOutput.text = "Started";
//			else if (e.quest is GametimeQuest)
//				_gametimeOutput.text = "Started";
//			else if (e.quest is StepQuest)
//				_stepOutput.text = "Started";
		}
		private function questUpdate_Handler(e:QuestEvent):void
		{
//			if (e.quest is RealtimeQuest)
//				_realtimeOutput.text = (e.quest.percentDone * 100).toFixed() + "%";
//			else if (e.quest is GametimeQuest)
//				_gametimeOutput.text = (e.quest.percentDone * 100).toFixed() + "%";
//			else if (e.quest is StepQuest)
//				_stepOutput.text = (e.quest.percentDone * 100).toFixed() + "%";
		}
		private function questComplete_Handler(e:QuestEvent):void 
		{
			setTestButtonVisibilitiesAndOutputs();
		}
		//*********************************************************
		//
		//                 MINION EVENT HANDLERS
		//
		//*********************************************************
		private function minionAdded_Handler(e:MinionEvent):void
		{
			recalculateMinionCounts();
		}
		private function minionRemoved_Handler(e:MinionEvent):void
		{
			recalculateMinionCounts();
		}
		private function recalculateMinionCounts():void
		{
			_minionsTotalCount.text = MinionManager.instance.minionCount + " minions total";
			var minionsOnQuests:Number = 0;
			for (var i:Number = 0; i < MinionManager.instance.minionCount; ++i)
			{
				if (MinionManager.instance.getMinionByIndex(i).questId != -1)
					++minionsOnQuests;
			}
			_minionsOnQuestsCount.text = minionsOnQuests + " minions on quests";
		}
	}
}

