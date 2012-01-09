package managers.minions 
{
	/**
	 * A struct for building a new minion with stats other than the defaults
	 * @author Jed Lang
	 */
	public class MinionBuilder 
	{
		public var fighterStat:Number = Minion.defaultFighterStat;
		public var mageStat:Number = Minion.defaultMageStat;
		public var gathererStat:Number = Minion.defaultGathererStat;
		public var builderStat:Number = Minion.defaultBuilderStat;
	}
}