package states.play 
{
	import com.junkbyte.console.Cc;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import managers.city.buildings.Building;
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
	public class PreBuildDisplay extends FlxGroup implements IEventDispatcher
	{
		//Event const
		public static const BUILDDISPLAY_OK:String = "BuildDisplay_OK";
		public static const BUILDDISPLAY_CANCEL:String = "BuildDisplay_Cancel";
		
		
		private var _xPos:Number = FlxG.width / 2 - 100;
		private var _yPos:Number = FlxG.height / 2 - 100;
		
		private var _buildingCls:Class = null;
		public function get buildingCls():Class { return _buildingCls; }
		private var _building:Building = null;
		public function get building():Building { return _building; }
		
		private var _availableMinionCount:Number = 0;
		private var _showingMinionIndex:Number = -1;
		public function get showingMinionIndex():Number { return _showingMinionIndex; }
		
		private var _eventDispatcher:EventDispatcher;
		
		//UI
		private var _buildingNameText:FlxText;
		private var _buildingCostText:FlxText;
		
		private var _minionName:FlxText;
		private var _minionIndex:FlxText;
		private var _minionTotal:FlxText;
		private var _minionFighterLabel:FlxText;
		private var _minionFighterStat:FlxText;
		private var _minionMageLabel:FlxText;
		private var _minionMageStat:FlxText;
		private var _minionGathererLabel:FlxText;
		private var _minionGathererStat:FlxText;
		private var _minionBuilderLabel:FlxText;
		private var _minionBuilderStat:FlxText;
		
		private var _nextMinionButton:FlxButton;
		private var _prevMinionButton:FlxButton;
		
		private var _okButton:FlxButton;
		private var _cancelButton:FlxButton;
		
		
		public function PreBuildDisplay(buildingCls:Class) 
		{
			if (!buildingCls)
				Cc.error("Invalid building class: " + buildingCls);
			_buildingCls = buildingCls;
			_building = new buildingCls();
			
						
			for (var i:Number = 0; i < MinionManager.instance.minionCount; ++i)
			{
				var minion:Minion = MinionManager.instance.getMinionByIndex(i);
				if (minion.questId == -1)										//Not on a quest
				{
					if (minion.builderStat >= _building.minSkillToBuild)		//Builder skill
					{
						if (_showingMinionIndex == -1)
							_showingMinionIndex = i;
						++_availableMinionCount;
					}
				}
			}
			
			_buildingNameText = new FlxText(_xPos - 40, _yPos + 10, 200, _building.name);
			//TODO: Find a way to display resource cost
			//_buildingCostText = new FlxText(_xPos + 10, _yPos + 30, 200, _building.resourceCost);
			//_buildingCostText.height = 60;
			add(_buildingNameText);
			add(_buildingCostText);
			
			_minionName = new FlxText(_xPos - 80, _yPos + 60, 200);
			_minionIndex = new FlxText(_xPos - 80, _yPos + 80, 100);
			_minionTotal = new FlxText(_xPos, _yPos + 80, 100, "/" + _availableMinionCount.toString());
			add(_minionName);
			add(_minionIndex);
			add(_minionTotal);
			
			_minionFighterLabel = new FlxText(_xPos - 160, _yPos + 100, 100, "Fighter: ");
			_minionMageLabel = new FlxText(_xPos - 160, _yPos + 120, 100, "Mage: ");
			_minionGathererLabel = new FlxText(_xPos - 160, _yPos + 140, 100, "Gatherer: ");
			_minionBuilderLabel = new FlxText(_xPos - 160, _yPos + 160, 100, "Builder: ");
			add(_minionFighterLabel);
			add(_minionMageLabel);
			add(_minionGathererLabel);
			add(_minionBuilderLabel);
			_minionFighterStat = new FlxText(_xPos - 80, _yPos + 100, 100);
			_minionMageStat = new FlxText(_xPos - 80, _yPos + 120, 100);
			_minionGathererStat = new FlxText(_xPos - 80, _yPos + 140, 100);
			_minionBuilderStat = new FlxText(_xPos - 80, _yPos + 160, 100);
			add(_minionFighterStat);
			add(_minionMageStat);
			add(_minionGathererStat);
			add(_minionBuilderStat);
			
			_nextMinionButton = new FlxButton(_xPos, _yPos + 200, "Next", nextMinion_Click);
			_prevMinionButton = new FlxButton(_xPos - 80, _yPos + 200, "Prev", prevMinion_Click);
			add(_nextMinionButton);
			add(_prevMinionButton);
			
			_okButton = new FlxButton(_xPos - 80, _yPos + 240, "OK", ok_Click);
			_cancelButton = new FlxButton(_xPos, _yPos + 240, "Cancel", cancel_Click);
			add(_okButton);
			add(_cancelButton);
			
			Cc.log("Available minions: " + _availableMinionCount.toString());
			setMinionTexts();
			
			_eventDispatcher = new EventDispatcher(this);
		}
		//This function relies on _showingMinionIndex being set correctly beforehand!
		private function setMinionTexts():void
		{
			Cc.log("Showing minion index: " + _showingMinionIndex.toString());
			var minion:Minion = MinionManager.instance.getMinionByIndex(_showingMinionIndex);
			_minionName.text = minion.name;
			_minionIndex.text = _showingMinionIndex.toString();
			_minionFighterStat.text = minion.fighterStat.toString();
			_minionMageStat.text = minion.mageStat.toString();
			_minionGathererStat.text = minion.gathererStat.toString();
			_minionBuilderStat.text = minion.builderStat.toString();
		}
		
		
		//******************************************************
		//
		//                BUTTON CLICK HANDLERS
		//
		//******************************************************
		private function nextMinion_Click():void
		{
			_showingMinionIndex = (_showingMinionIndex + 1) % _availableMinionCount;
			setMinionTexts();
		}
		private function prevMinion_Click():void
		{
			_showingMinionIndex = _showingMinionIndex - 1;
			//Extra logic because looping trick doesn't work when going backwards
			if (_showingMinionIndex < 0)
				_showingMinionIndex = _availableMinionCount - 1;
			setMinionTexts();
		}
		private function ok_Click():void
		{
			dispatchEvent(new Event(BUILDDISPLAY_OK));
		}
		private function cancel_Click():void
		{
			dispatchEvent(new Event(BUILDDISPLAY_CANCEL));
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