package managers.minions 
{
	import managers.quests.IRewardSource;
	/**
	 * ...
	 * @author Jed Lang
	 */
	public class MinionStatCollection implements IRewardSource
	{
		private var _stats:MinionBuilder = new MinionBuilder();
		
		
		public function MinionStatCollection(fighter:Number=0, mage:Number=0, gatherer:Number=0, builder:Number=0) 
		{
			_stats.fighterStat = fighter;
			_stats.mageStat = mage;
			_stats.gathererStat = gatherer;
			_stats.builderStat = builder;
		}
		
		
		public function get fighterStat():Number { return _stats.fighterStat; }
		public function set fighterStat(value:Number):void { _stats.fighterStat = value; }
		public function get mageStat():Number { return _stats.mageStat; }
		public function set mageStat(value:Number):void { _stats.mageStat = value; }
		public function get gathererStat():Number { return _stats.gathererStat; }
		public function set gathererStat(value:Number):void { _stats.gathererStat = value; }
		public function get builderStat():Number { return _stats.builderStat; }
		public function set builderStat(value:Number):void { _stats.builderStat = value; }
	}
}