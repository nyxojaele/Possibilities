package managers.quests 
{
	import com.cinder.common.config.Configuration;
	import flash.net.URLVariables;
	import managers.minions.MinionBuilderCollection;
	import managers.minions.MinionStatCollection;
	import managers.resources.ResourceCollection;
	/**
	 * A quest that completes over time, whether the user is online or not
	 * @author Jed Lang
	 */
	public class RealtimeQuest extends Quest 
	{
		public static function get questTypeString():uint { return Quest.QUESTTYPE_REALTIME; }
		
		
		private var _startTime:Number = 0;
		private var _endTime:Number = 0;
		private function get deltaTime():Number
		{
			return _endTime - _startTime;
		}
		
		public override function get percentDone():Number
		{
			var now:Number = valueCurrent;
			var timespan:Number = now - _startTime;
			var percent:Number = timespan / deltaTime;
			if (percent > 1)
				percent = 1;
			return percent;
		}
		public override function get valueCurrent():Number
		{
			return new Date().valueOf();
		}
		public override function get valueGoal():Number
		{
			return _endTime;
		}
		
		
		public function RealtimeQuest(id:Number, questId:Number=-1, name:String="", repeatable:Boolean=false,
			description:String="", completeText:String="", xPos:Number=0, yPos:Number=0, lengthInS:Number=0,
			unlockQuestIds:Array=null,
			rewardResources:ResourceCollection = null, rewardMinions:MinionBuilderCollection = null, rewardMinionStats:MinionStatCollection = null,
			requiredStats:MinionStatCollection = null)
		{
			if (Configuration.instance.DebugMode)
				_endTime = lengthInS * 1000 / 60;
			else
				_endTime = lengthInS * 1000;
			super(id, questId, name, repeatable, description, completeText, xPos, yPos, unlocksQuestIds, rewardResources, rewardMinions, rewardMinionStats, requiredStats);
		}
		
		
		public override function initFromServerData(properties:Array):Boolean
		{
			if (properties.length < 4 ||
				isNaN(Number(properties[2])) ||
				isNaN(Number(properties[3])))
				return false;
			var state:uint = Number(properties[2]);
			if (state == Quest.QUESTSTATE_STARTED)
				_startTime = Number(properties[3]);
			return super.initFromServerData(properties);
		}
		public override function start():void
		{
			_startTime = new Date().valueOf();
			_endTime += _startTime;
		}
		public override function reset():void
		{
			_endTime -= _startTime;
			_startTime = 0;
		}
		public override function populateStartRequest(request:URLVariables):void
		{
			request.startTime = _startTime;
		}
		
		
		public override function update():Boolean 
		{
			_updatePending = true;
			var now:Date = new Date();
			if (now.valueOf() >= _endTime)
				return true;
			return false;
		}
	}
}