package managers.quests 
{
	
	/**
	 * This represents a reward for a quest
	 * @author Jed Lang
	 */
	public class Reward 
	{
		private var _source:IRewardSource;
		private var _target:IRewardTarget;
		
		
		public function Reward(source:IRewardSource, target:IRewardTarget)
		{
			_source = source;
			_target = target;
		}
		
		
		public function apply(applyToQuestId:uint):void
		{
			if (_source && _target)
				_target.applyReward(_source, applyToQuestId);
		}
	}
	
}