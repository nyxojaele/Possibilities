package states 
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
	import org.flixel.Flx9SliceSprite;
	import org.flixel.FlxBasic;
	import org.flixel.FlxButton;
	import org.flixel.FlxG;
	import org.flixel.FlxGroup;
	import org.flixel.FlxRect;
	import org.flixel.FlxText;
	/**
	 * ...
	 * @author Jed Lang
	 */
	public class MinionSelector extends FlxGroup implements IEventDispatcher
	{
		//Event const
		public static const MINIONSELECTOR_OK:String = "MinionSelector_OK";
		public static const MINIONSELECTOR_CANCEL:String = "MinionSelector_Cancel";
		
		
		public var userData:* = null;
		
		private var _xPos:Number = FlxG.width / 2 - 125;
		private var _yPos:Number = FlxG.height / 2 - 140;
		private var _width:Number = 250;
		private var _height:Number = 280;
		
		private var _availableMinionCount:Number = 0;
		private var _showingMinionIndex:Number = -1;
		public function get showingMinionIndex():Number { return _showingMinionIndex; }
		
		private var _eventDispatcher:EventDispatcher;
		
		//UI
		private var _bg:Flx9SliceSprite;
		
		private var _headerText:FlxText;
		private var _contentText:FlxText;
		
		private var _minionName:FlxText;
		private var _minionIndex:FlxText;
		private var _minionTotal:FlxText;
		
		private var _minionFighterLabel:FlxText;
		private var _minionFighterStat:FlxText;
		private var _minFighterStat:FlxText;
		private var _minionMageLabel:FlxText;
		private var _minionMageStat:FlxText;
		private var _minMageStat:FlxText;
		private var _minionGathererLabel:FlxText;
		private var _minionGathererStat:FlxText;
		private var _minGathererStat:FlxText;
		private var _minionBuilderLabel:FlxText;
		private var _minionBuilderStat:FlxText;
		private var _minBuilderStat:FlxText;
		
		private var _nextMinionButton:FlxButton;
		private var _prevMinionButton:FlxButton;
		
		private var _okButton:FlxButton;
		private var _cancelButton:FlxButton;
		
		
		public function MinionSelector(header:String, content:String="", userData:*=null, minFighterStat:Number=0, minMageStat:Number=0, minGathererStat:Number=0, minBuilderStat:Number=0) 
		{
			this.userData = userData;
			
			for (var i:Number = 0; i < MinionManager.instance.minionCount; ++i)
			{
				var minion:Minion = MinionManager.instance.getMinionByIndex(i);
				if (minion.questId == -1)										//Not on a quest
				{
					if (minion.fighterStat >= minFighterStat &&
						minion.mageStat >= minMageStat &&
						minion.gathererStat >= minGathererStat &&
						minion.builderStat >= minBuilderStat)
					{
						if (_showingMinionIndex == -1)
							_showingMinionIndex = i;
						++_availableMinionCount;
					}
				}
			}
			
			_bg = new Flx9SliceSprite(_xPos, _yPos, _width, _height, Pilot.POPUPIMG_PNG, new FlxRect(4, 4, 56, 56));
			add(_bg);
			
			_headerText = new FlxText(_xPos + _width / 2 - 30, _yPos + 10, 200, header);
			_contentText = new FlxText(_xPos + 10, _yPos + 30, 200, content);
			_contentText.height = 60;
			add(_headerText);
			add(_contentText);
			
			_minionName = new FlxText(_xPos + _width / 2 - 80, _yPos + 60, 200);
			_minionIndex = new FlxText(_xPos + _width / 2 - 80, _yPos + 80, 30);
			_minionTotal = new FlxText(_xPos + _width / 2 - 50, _yPos + 80, 100, "/" + _availableMinionCount.toString());
			add(_minionName);
			add(_minionIndex);
			add(_minionTotal);
			
			_minionFighterLabel = new FlxText(_xPos + _width / 2 - 80, _yPos + 100, 60, "Fighter: ");
			_minionMageLabel = new FlxText(_xPos + _width / 2 - 80, _yPos + 120, 60, "Mage: ");
			_minionGathererLabel = new FlxText(_xPos + _width / 2 - 80, _yPos + 140, 60, "Gatherer: ");
			_minionBuilderLabel = new FlxText(_xPos + _width / 2 - 80, _yPos + 160, 60, "Builder: ");
			add(_minionFighterLabel);
			add(_minionMageLabel);
			add(_minionGathererLabel);
			add(_minionBuilderLabel);
			_minionFighterStat = new FlxText(_xPos + _width / 2 - 20, _yPos + 100, 30);
			_minionMageStat = new FlxText(_xPos + _width / 2 - 20, _yPos + 120, 30);
			_minionGathererStat = new FlxText(_xPos + _width / 2 - 20, _yPos + 140, 30);
			_minionBuilderStat = new FlxText(_xPos + _width / 2 - 20, _yPos + 160, 30);
			add(_minionFighterStat);
			add(_minionMageStat);
			add(_minionGathererStat);
			add(_minionBuilderStat);
			_minFighterStat = new FlxText(_xPos + _width / 2 + 60, _yPos + 100, 60, "(min " + minFighterStat + ")");
			_minMageStat = new FlxText(_xPos + _width / 2 + 60, _yPos + 120, 60, "(min " + minMageStat + ")");
			_minGathererStat = new FlxText(_xPos + _width / 2 + 60, _yPos + 140, 60, "(min " + minGathererStat + ")");
			_minBuilderStat = new FlxText(_xPos + _width / 2 + 60, _yPos + 160, 60, "(min " + minBuilderStat + ")");
			
			_nextMinionButton = new FlxButton(_xPos + _width / 2, _yPos + 200, "Next", nextMinion_Click);
			_prevMinionButton = new FlxButton(_xPos + _width / 2 - 80, _yPos + 200, "Prev", prevMinion_Click);
			add(_nextMinionButton);
			add(_prevMinionButton);
			
			_okButton = new FlxButton(_xPos + _width / 2 - 80, _yPos + 240, "OK", ok_Click);
			_cancelButton = new FlxButton(_xPos + _width / 2, _yPos + 240, "Cancel", cancel_Click);
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
			dispatchEvent(new Event(MINIONSELECTOR_OK));
		}
		private function cancel_Click():void
		{
			dispatchEvent(new Event(MINIONSELECTOR_CANCEL));
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