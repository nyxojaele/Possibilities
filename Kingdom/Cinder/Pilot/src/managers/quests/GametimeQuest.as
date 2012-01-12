package managers.quests 
{
	import flash.net.URLVariables;
	import managers.minions.MinionBuilderCollection;
	import managers.minions.MinionStatCollection;
	import managers.resources.ResourceCollection;
	/**
	 * A quest that completes over time, but only if the user is online
	 * @author Jed Lang
	 */
	public class GametimeQuest extends Quest 
	{
		private static const serverUpdateDelayMs:Number = 60000;	//Time in ms between updates to the server about current progress
		
		private var _lastServerUpdateAt:Number = 0;	//Time this quest last updated the server with current status
		private var _startedAt:Number = 0;			//Time this quest was started most recently (_baseTimeSoFarMs was set at this time)
		private var _lengthMs:Number = 0;			//Total length of time this quest will last
		private var _baseTimeSoFarMs:Number = 0;	//Most recently set time for this quest, often this will be the time loaded from the server for an unfinished quest
		private var _timeSoFarMs:Number = 0;		//This is the time that has elapsed since _startedAt
		
		public override function get percentDone():Number
		{
			return valueCurrent / valueGoal;
		}
		public override function get valueCurrent():Number
		{
			return _baseTimeSoFarMs + _timeSoFarMs;
		}
		public override function get valueGoal():Number
		{
			return _lengthMs;
		}
		
		
		public function GametimeQuest(id:Number, questId:Number, name:String = "", description:String = "", completeText:String="" xPos:Number = 0, yPos:Number = 0, lengthInMs:uint = 30000, startingTime:uint = 0,
			unlockQuestIds:Array=null,
			rewardResources:ResourceCollection = null, rewardMinions:MinionBuilderCollection = null, rewardMinionStats:MinionStatCollection = null) 
		{
			_lengthMs = lengthInMs;
			_timeSoFarMs = startingTime;
			super(id, questId, name, description, completeText, xPos, yPos, unlockQuestIds, rewardResources, rewardMinions, rewardMinionStats);
		}
		
		
		public override function initFromServerData(properties:Array):Boolean
		{
			if (properties.length < 4 ||
				isNaN(Number(properties[2])) ||
				isNaN(Number(properties[3])))
				return false;
			var state:uint = Number(properties[2]);
			if (state == Quest.QUESTSTATE_STARTED)
			{
				var now:Number = new Date().valueOf();
				_baseTimeSoFarMs = Number(properties[3]);
				_startedAt = now;
				_lastServerUpdateAt = now;
			}
			return super.initFromServerData(properties);
		}
		public override function start():void
		{
			var now:Number = new Date().valueOf();
			_startedAt = now;
			_lastServerUpdateAt = now;
			_baseTimeSoFarMs = valueCurrent;
			_timeSoFarMs = 0;
		}
		public override function reset():void
		{
			_timeSoFarMs = 0;
			_baseTimeSoFarMs = 0;
			_lastServerUpdateAt = 0;
			_startedAt = 0;
		}
		public override function populateAvailableRequest(request:URLVariables):void
		{
			request.type = QUESTTYPE_GAMETIME;
		}
		public override function populateUpdateRequest(request:URLVariables):void
		{
			request.timeSoFarMs = valueCurrent;
		}
		public override function populateFinishRequest(request:URLVariables):void
		{
			request.timeSoFarMs = valueCurrent;
		}
		
		
		public override function update():Boolean
		{
			_updatePending = true;
			var now:Number= new Date().valueOf();
			_timeSoFarMs = now - _startedAt;
			
			//Check to see if we should update the server with our current progress
			if ((now - _lastServerUpdateAt) > serverUpdateDelayMs)
			{
				_lastServerUpdateAt = now;
				_shouldUpdateServer = true;
			}
			
			if ((_baseTimeSoFarMs + _timeSoFarMs) > _lengthMs)
			{
				_timeSoFarMs = _lengthMs - _baseTimeSoFarMs;
				return true;
			}
			return false;
		}
	}
}