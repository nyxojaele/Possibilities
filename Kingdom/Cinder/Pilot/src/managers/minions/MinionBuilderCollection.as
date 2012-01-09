package managers.minions 
{
	import managers.ItemCollection;
	/**
	 * ...
	 * @author Jed Lang
	 */
	public class MinionBuilderCollection extends ItemCollection
	{
		private static const _empty:MinionBuilderCollection = new MinionBuilderCollection();
		public static function get empty():MinionBuilderCollection { return _empty; }
		
		
		public function MinionBuilderCollection(minions:Array=null) 
		{
			if (minions)
			{
				for each (var builder:MinionBuilder in minions)
					addMinionBuilder(builder);
			}
		}
		
		
		public function addMinionBuilder(builder:MinionBuilder):void
		{
			addItem(builder);
		}
		public function get minionBuilderCount():Number { return itemCount; }
		public function getMinionBuilderByIndex(idx:Number):MinionBuilder
		{
			return getItem(idx) as MinionBuilder;
		}
	}
}