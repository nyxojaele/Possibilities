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
		
		public function MinionBuilder(fighterStat:Number=1, mageStat:Number=1, gathererStat:Number=1, builderStat:Number=1)
		{
			this.fighterStat = fighterStat;
			this.mageStat = mageStat;
			this.gathererStat = gathererStat;
			this.builderStat = builderStat;
		}
	}
}