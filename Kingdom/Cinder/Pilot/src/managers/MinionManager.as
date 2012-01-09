package managers 
{
	import com.junkbyte.console.Cc;
	import flash.net.URLVariables;
	import flash.utils.getDefinitionByName;
	import managers.minions.Minion;
	import managers.minions.MinionBuilder;
	import managers.minions.MinionBuilderCollection;
	import managers.minions.MinionEvent;
	import managers.minions.MinionStatCollection;
	import managers.quests.IRewardSource;
	import managers.quests.IRewardTarget;
	import org.flixel.FlxU;
	/**
	 * ...
	 * @author Jed Lang
	 */
	public class MinionManager extends Manager implements IRewardTarget
	{
		//Singleton
		private static var _instance:MinionManager;
		public static function get instance():MinionManager
		{
			if (!_instance)
				_instance = new MinionManager();
			return _instance;
		}
		
		
		public static function getRandomMinionName():String
		{
			return (String)(FlxU.getRandom([
				"Bob",
				"Steve"
				]));
		}
		public static function getRandomMinionSex():uint
		{
			return (uint)(FlxU.getRandom([Minion.MINION_SEXMALE, Minion.MINION_SEXFEMALE]));
		}
		
		
		private var _minions:Array;
		public function get minionCount():Number { return _minions.length; }
		public function minionCountByClass(className:String):Number
		{
			var count:Number = 0;
			for each (var minion:Minion in _minions)
			{
				if (minion.minionClass == className)
					++count;
			}
			return count;
		}
		public function getMinionByIndex(idx:Number):Minion
		{
			return _minions[idx];
		}
		
		
		public function MinionManager() 
		{
			super("minions.php", requestReturn);
			_minions = [];
		}
		
		
		//**********************************************************************
		//
		//                            SERVER DATA
		//
		//**********************************************************************
		protected override function getMemberClassByTypeId(typeId:uint):Class
		{
			//There's only 1 minion class
			return getDefinitionByName("managers.minions::Minion") as Class;
		}
		protected override function hydrateMemberWithServerData(member:ManagedItem, properties:Array):Boolean
		{
			var workingMinion:Minion = member as Minion;			
			if (!workingMinion.initFromServerData(properties))	//Initialize minion
				return false;
			_minions.push(workingMinion);
			dispatchEvent(new MinionEvent(MinionEvent.MINION_ADDED, workingMinion));
			return true;
		}
		
		private function sendAddMinionRequest(minion:Minion):void
		{
			minion.setID( -Manager.requestID);	//Done before makeRequest so we get the value before it's incremented.
			//This should always be the first thing done for a minion in the DB,
			//so this is how it gets instantiated.
			var request:URLVariables = makeRequest("add");
			if (request)
			{
				request.name = minion.name;
				request.sex = minion.sex;
				request.fighterStat = minion.fighterStat;
				request.mageStat = minion.mageStat;
				request.gathererStat = minion.gathererStat;
				request.builderStat = minion.builderStat;
				//Minions always start with null questId
				
				sendRequest(request);
			}
		}
		private function sendRemoveMinionRequest(minion:Minion):void
		{
			var request:URLVariables = makeRequest("remove");
			if (request)
			{
				request.id = minion.id;
				sendRequest(request);
			}
		}
		private function sendMinionQuestRequest(minion:Minion):void
		{
			var request:URLVariables = makeRequest("setquest");
			if (request)
			{
				request.id = minion.id;
				request.questId = minion.questId;
				sendRequest(request);
			}
		}
		private function sendMinionStatRequest(minion:Minion):void
		{
			var request:URLVariables = makeRequest("setStats");
			if (request)
			{
				request.id = minion.id;
				request.fighterStat = minion.fighterStat;
				request.mageStat = minion.mageStat;
				request.gathererStat = minion.gathererStat;
				request.builderStat = minion.builderStat;
				sendRequest(request);
			}
		}
		
		private function requestReturn(e:ManagerEvent):void
		{
			var vars:URLVariables = new URLVariables(e.data);
			if (vars.Action == "create")
			{
				//Find minion by ID
				for each (var minion:Minion in _minions)
				{
					if (minion.id == -vars.RequestID)
					{
						minion.setID(vars.NewID);
						break;
					}
				}
			}
		}
		
		
		//**********************************************************************
		//
		//                         NORMAL FUNCTIONS
		//
		//**********************************************************************
		public function addNewMinion(name:String, sex:uint, builder:MinionBuilder=null):Minion
		{
			var minion:Minion = null;
			if (builder)
				minion = Minion.FromBuilder(name, sex, builder);
			else
				minion = new Minion(-1, name, sex);
			_minions.push(minion);
			dispatchEvent(new MinionEvent(MinionEvent.MINION_ADDED, minion));
			sendAddMinionRequest(minion);
			return minion;
		}
		public function removeMinion(minion:Minion):void
		{
			var idx:Number = _minions.indexOf(minion);
			if (idx != -1)
			{
				_minions.splice(idx, 1);
				dispatchEvent(new MinionEvent(MinionEvent.MINION_REMOVED, minion));
			}
			sendRemoveMinionRequest(minion);
		}
		public function assignQuestToMinion(minion:Minion, questId:Number):void
		{
			minion.questId = questId;
			dispatchEvent(new MinionEvent(MinionEvent.MINION_QUESTSET, minion));
			sendMinionQuestRequest(minion);
		}
		public function clearQuestIdFromMinions(questId:uint):void
		{
			for each(var minion:Minion in _minions)
			{
				if (minion.questId == questId)
				{
					minion.questId = -1;
					sendMinionQuestRequest(minion);
				}
			}
		}
		
		
		/* INTERFACE managers.quests.IRewardTarget */
		public function applyReward(source:IRewardSource, applyToQuestId:uint):void 
		{
			if (source is MinionBuilderCollection)
			{
				var bc:MinionBuilderCollection = source as MinionBuilderCollection;
				for (var i:Number = 0; i < bc.minionBuilderCount; ++i)
					addNewMinion(MinionManager.getRandomMinionName(), MinionManager.getRandomMinionSex(), bc.getMinionBuilderByIndex(i));
			}
			else if (source is MinionStatCollection)
			{
				var sc:MinionStatCollection = source as MinionStatCollection;
				for each (var minion:Minion in _minions)
				{
					if (minion.questId == applyToQuestId)
					{
						minion.increaseFighterStatBy(sc.fighterStat);
						minion.increaseMageStatBy(sc.mageStat);
						minion.increaseGathererStatBy(sc.gathererStat);
						minion.increaseBuilderStatBy(sc.builderStat);
						sendMinionStatRequest(minion);
					}
				}
			}
		}
	}

}