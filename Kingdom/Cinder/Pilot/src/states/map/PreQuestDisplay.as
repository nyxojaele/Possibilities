package states.map 
{
	import com.junkbyte.console.Cc;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import managers.MinionManager;
	import managers.minions.Minion;
	import managers.QuestManager;
	import managers.quests.Quest;
	import org.flixel.FlxBasic;
	import org.flixel.FlxButton;
	import org.flixel.FlxG;
	import org.flixel.FlxGroup;
	import org.flixel.FlxText;
	/**
	 * ...
	 * @author Jed Lang
	 */
	public class PreQuestDisplay extends FlxGroup implements IEventDispatcher
	{
		//Event const
		public static const QUESTDISPLAY_OK:String = "QuestDisplay_OK";
		public static const QUESTDISPLAY_CANCEL:String = "QuestDisplay_Cancel";
		
		
		private var _xPos:Number = FlxG.width / 2 - 140;
		private var _yPos:Number = FlxG.height / 2 - 130;
		
		private var _questId:Number = -1;
		public function get questId():Number { return _questId; }
		private var _quest:Quest;
		
		private var _usedFighters:Number = 0;
		private var _usedMages:Number = 0;
		private var _usedGatherers:Number = 0;
		private var _usedBuilders:Number = 0;
		
		private var _availableFighters:Number = 0;
		private var _availableMages:Number = 0;
		private var _availableGatherers:Number = 0;
		private var _availableBuilders:Number = 0;
		
		private var _eventDispatcher:EventDispatcher;
		
		//UI
		private var _questNameText:FlxText;
		private var _questDescText:FlxText;
		
		private var _availableMinionsLabel:FlxText;
		private var _availableMinionsText:FlxText;
		
		private var _availableFightersLabel:FlxText;
		private var _availableFightersText:FlxText;
		private var _addFighterButton:FlxButton;
		private var _removeFighterButton:FlxButton;
		
		private var _availableMagesLabel:FlxText;
		private var _availableMagesText:FlxText;
		private var _addMageButton:FlxButton;
		private var _removeMageButton:FlxButton;
		
		private var _availableGatherersLabel:FlxText;
		private var _availableGatherersText:FlxText;
		private var _addGathererButton:FlxButton;
		private var _removeGathererButton:FlxButton;
		
		private var _availableBuildersLabel:FlxText;
		private var _availableBuildersText:FlxText;
		private var _addBuilderButton:FlxButton;
		private var _removeBuilderButton:FlxButton;
		
		private var _okButton:FlxButton;
		private var _cancelButton:FlxButton;
		
		
		public function PreQuestDisplay(questId:Number) 
		{
			if (questId < 0)
				Cc.error("Invalid questId: " + questId);
			_questId = questId;
			_quest = QuestManager.questLibrary[questId];
			if (!_quest)
				Cc.error("Cannot setup a null quest!");
			
			for (var i:Number = 0; i < MinionManager.instance.minionCount; ++i)
			{
				var minion:Minion = MinionManager.instance.getMinionByIndex(i);
				if (minion.questId == -1)										//Not on a quest
				{
					if (minion.minionClass == Minion.FighterClassName)			//Fighters
						++_availableFighters;
					else if (minion.minionClass == Minion.MageClassName )		//Mages
						++_availableMages;
					else if (minion.minionClass == Minion.GathererClassName)	//Gatherers
						++_availableGatherers;
					else if (minion.minionClass == Minion.BuilderClassName)		//Builders
						++_availableBuilders;
				}
			}
			
			_questNameText = new FlxText(_xPos + 10, _yPos + 10, 200, _quest.name);
			add(_questNameText);
			_questDescText = new FlxText(_xPos + 10, _yPos + 30, 200, _quest.description);
			_questDescText.height = 60;
			add(_questDescText);
			
			_availableMinionsLabel = new FlxText(_xPos + 10, _yPos + 100, 70, "Minions: ");
			add(_availableMinionsLabel);
			_availableMinionsText = new FlxText(_xPos + 80, _yPos + 100, 70);
			add(_availableMinionsText);
			
			_availableFightersLabel = new FlxText(_xPos + 10, _yPos + 120, 70, "Fighters: ");
			add(_availableFightersLabel);
			_availableFightersText = new FlxText(_xPos + 80, _yPos + 120, 30);
			add(_availableFightersText);
			_addFighterButton = new FlxButton(_xPos + 120, _yPos + 120, "+", addFighter_Click);
			add(_addFighterButton);
			_removeFighterButton = new FlxButton(_xPos + 200, _yPos + 120, "-", removeFighter_Click);
			add(_removeFighterButton);
			
			_availableMagesLabel = new FlxText(_xPos + 10, _yPos + 140, 70, "Mages: ");
			add(_availableMagesLabel);
			_availableMagesText = new FlxText(_xPos + 80, _yPos + 140, 30);
			add(_availableMagesText);
			_addMageButton = new FlxButton(_xPos + 120, _yPos + 140, "+", addMage_Click);
			add(_addMageButton);
			_removeMageButton = new FlxButton(_xPos + 200, _yPos + 140, "-", removeMage_Click);
			add(_removeMageButton);
			
			_availableGatherersLabel = new FlxText(_xPos + 10, _yPos + 160, 70, "Gatherers: ");
			add(_availableGatherersLabel);
			_availableGatherersText = new FlxText(_xPos + 80, _yPos + 160, 30);
			add(_availableGatherersText);
			_addGathererButton = new FlxButton(_xPos + 120, _yPos + 160, "+", addGatherer_Click);
			add(_addGathererButton);
			_removeGathererButton = new FlxButton(_xPos + 200, _yPos + 160, "-", removeGatherer_Click);
			add(_removeGathererButton);
			
			_availableBuildersLabel = new FlxText(_xPos + 10, _yPos + 180, 70, "Builders: ");
			add(_availableBuildersLabel);
			_availableBuildersText = new FlxText(_xPos + 80, _yPos + 180, 30);
			add(_availableBuildersText);
			_addBuilderButton = new FlxButton(_xPos + 120, _yPos + 180, "+", addBuilder_Click);
			add(_addBuilderButton);
			_removeBuilderButton = new FlxButton(_xPos + 200, _yPos + 180, "-", removeBuilder_Click);
			add(_removeBuilderButton);
			
			_okButton = new FlxButton(_xPos + 20, _yPos + 240, "OK", ok_Click);
			add(_okButton);
			_cancelButton = new FlxButton(_xPos + 100, _yPos + 240, "Cancel", cancel_Click);
			add(_cancelButton);
			
			initTexts();
			
			_eventDispatcher = new EventDispatcher(this);
		}
		private function initTexts():void
		{
			initMinionsText();
			initFightersText();
			initMagesText();
			initGatherersText();
			initBuildersText();
		}
		private function initMinionsText():void
		{
			var notOnQuests:Number = 0;
			for (var i:Number = 0; i < MinionManager.instance.minionCount; ++i)
			{
				if (MinionManager.instance.getMinionByIndex(i).questId == -1)
					++notOnQuests;
			}
			_availableMinionsText.text = (_availableFighters + _availableMages + _availableGatherers + _availableBuilders - _usedFighters - _usedMages - _usedGatherers - _usedBuilders).toString();
		}
		private function initFightersText():void
		{
			_availableFightersText.text = (_availableFighters - _usedFighters).toString();
		}
		private function initMagesText():void
		{
			_availableMagesText.text = (_availableMages - _usedMages).toString();
		}
		private function initGatherersText():void
		{
			_availableGatherersText.text = (_availableGatherers - _usedGatherers).toString();
		}
		private function initBuildersText():void
		{
			_availableBuildersText.text = (_availableBuilders - _usedBuilders).toString();
		}
		
		
		//******************************************************
		//
		//                BUTTON CLICK HANDLERS
		//
		//******************************************************
		private function addFighter_Click():void
		{
			if (_usedFighters < _availableFighters)
			{
				++_usedFighters;
				initMinionsText();
				initFightersText();
			}
		}
		private function removeFighter_Click():void
		{
			if (_usedFighters > 0)
			{
				--_usedFighters;
				initMinionsText();
				initFightersText();
			}
		}
		private function addMage_Click():void
		{
			if (_usedMages < _availableMages)
			{
				++_usedMages;
				initMinionsText();
				initMagesText();
			}
		}
		private function removeMage_Click():void
		{
			if (_usedMages > 0)
			{
				--_usedMages;
				initMinionsText();
				initMagesText();
			}
		}
		private function addGatherer_Click():void
		{
			if (_usedGatherers < _availableGatherers)
			{
				++_usedGatherers;
				initMinionsText();
				initGatherersText();
			}
		}
		private function removeGatherer_Click():void
		{
			if (_usedGatherers > 0)
			{
				--_usedGatherers;
				initMinionsText();
				initGatherersText();
			}
		}
		private function addBuilder_Click():void
		{
			if (_usedBuilders < _availableBuilders)
			{
				++_usedBuilders;
				initMinionsText();
				initBuildersText();
			}
		}
		private function removeBuilder_Click():void
		{
			if (_usedBuilders > 0)
			{
				--_usedBuilders;
				initMinionsText();
				initBuildersText();
			}
		}
		private function ok_Click():void
		{
			var completedFighters:Number = 0;
			var completedMages:Number = 0;
			var completedGatherers:Number = 0;
			var completedBuilders:Number = 0;
			for (var i:Number = 0; i < MinionManager.instance.minionCount; ++i)
			{
				var minion:Minion = MinionManager.instance.getMinionByIndex(i);
				if (minion.questId == -1)	//Not on a quest
				{
					switch (minion.minionClass)
					{
						case Minion.FighterClassName:
							{
								if (completedFighters < _usedFighters)
									++completedFighters;
								break;
							}
						case Minion.MageClassName:
							{
								if (completedMages < _usedMages)
									++completedMages;
								break;
							}
						case Minion.GathererClassName:
							{
								if (completedGatherers < _usedGatherers)
									++completedGatherers;
								break;
							}
						case Minion.BuilderClassName:
							{
								if (completedBuilders < _usedBuilders)
									++completedBuilders;
								break;
							}
					}
					MinionManager.instance.assignQuestToMinion(minion, _questId);
					if (completedFighters == _usedFighters &&
						completedMages == _usedMages &&
						completedGatherers == _usedGatherers &&
						completedBuilders == _usedBuilders)
					{
						dispatchEvent(new Event(QUESTDISPLAY_OK));
						return;
					}
				}
			}
		}
		private function cancel_Click():void
		{
			dispatchEvent(new Event(QUESTDISPLAY_CANCEL));
		}
		
		
		/* INTERFACE flash.events.IEventDispatcher */
		public function dispatchEvent(event:Event):Boolean 
		{
			return _eventDispatcher.dispatchEvent(event);
		}
		
		public function hasEventListener(type:String):Boolean 
		{
			return _eventDispatcher.hasEventListener(type);
		}
		
		public function willTrigger(type:String):Boolean 
		{
			return _eventDispatcher.willTrigger(type);
		}
		
		public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void 
		{
			_eventDispatcher.removeEventListener(type, listener, useCapture);
		}
		
		public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void 
		{
			_eventDispatcher.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}
	}

}