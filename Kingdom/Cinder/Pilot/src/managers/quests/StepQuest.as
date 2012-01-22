package managers.quests 
{
	import flash.net.URLVariables;
	import managers.city.buildings.Building_Quarters;
	import managers.city.CityEvent;
	import managers.CityManager;
	import managers.minions.MinionBuilderCollection;
	import managers.minions.MinionStatCollection;
	import managers.QuestManager;
	import managers.resources.ResourceCollection;
	/**
	 * A quest that completes via "steps" (such as how many times you've sent minions to it)
	 * @author Jed Lang
	 */
	public class StepQuest extends Quest 
	{
		public static function get questTypeString():uint { return Quest.QUESTTYPE_STEP; }
		
		
		private var _totalSteps:Number = 1;
		private var _lastCurrentSteps:Number = 0;
		private var _currentSteps:Number = 0;
		
		public override function get percentDone():Number
		{
			return _currentSteps / _totalSteps;
		}
		public override function get valueCurrent():Number
		{
			return _currentSteps;
		}
		public override function get valueGoal():Number
		{
			return _totalSteps;
		}
		
		
		public function StepQuest(id:Number, questId:Number = -1, name:String = "", repeatable:Boolean = false,
			description:String="", completeText:String="", xPos:Number=0, yPos:Number=0, totalSteps:Number=1,
			unlockQuestIds:Array=null,
			rewardResources:ResourceCollection=null, rewardMinions:MinionBuilderCollection=null, rewardMinionStats:MinionStatCollection=null,
			requiredStats:MinionStatCollection = null) 
		{
			_totalSteps = totalSteps;
			super(id, questId, name, repeatable, description, completeText, xPos, yPos, unlockQuestIds, rewardResources, rewardMinions, rewardMinionStats,  requiredStats);
		}
		
		
		public override function initFromServerData(properties:Array):Boolean
		{
			if (properties.length < 4 ||
				isNaN(Number(properties[2])) ||
				isNaN(Number(properties[3])))
				return false;
			var state:uint = Number(properties[2]);
			if (state == Quest.QUESTSTATE_STARTED)
				_currentSteps = Number(properties[3]);
			return super.initFromServerData(properties);
		}
		public override function updateValue(value:*=0):void
		{
			++_currentSteps;
		}
		public override function reset():void
		{
			_currentSteps = 0;
			_lastCurrentSteps = 0;
		}
		public override function populateStartRequest(request:URLVariables):void
		{
			request.currentSteps = valueCurrent;
		}
		public override function populateUpdateRequest(request:URLVariables):void
		{
			request.currentSteps = valueCurrent;
		}
		public override function populateFinishRequest(request:URLVariables):void
		{
			request.currentSteps = valueCurrent;
		}
		
		
		public override function update():Boolean
		{
			if (_lastCurrentSteps != _currentSteps)
			{
				//The value has changed since the last update
				_lastCurrentSteps = _currentSteps;
				_updatePending = true;
			}
			else
				_updatePending = false;
			
			return _currentSteps >= _totalSteps;
		}
	}
}