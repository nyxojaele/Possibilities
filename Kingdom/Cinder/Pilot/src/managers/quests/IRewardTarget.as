package managers.quests 
{
	
	/**
	 * This represents where a given IReward will be assigned to
	 * @author Jed Lang
	 */
	public interface IRewardTarget 
	{
		function applyReward(source:IRewardSource, applyToQuestId:uint):void;
	}
	
}