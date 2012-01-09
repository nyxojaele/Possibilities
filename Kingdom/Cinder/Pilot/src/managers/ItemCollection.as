package managers 
{
	import flash.utils.Dictionary;
	import managers.quests.IRewardSource;
	/**
	 * ...
	 * @author Jed Lang
	 */
	public class ItemCollection implements IRewardSource
	{
		private static const _empty:ItemCollection = new ItemCollection();
		public static function get empty():ItemCollection { return _empty; }
		
		
		//Derived classes can choose between an associative array and a normal one
		private var _itemsAssoc:Dictionary;
		private var _items:Array;
		
		
		public function ItemCollection()
		{
			_itemsAssoc = new Dictionary();
			_items = [];
		}
		
		
		protected function get itemCountAssoc():Number
		{
			var count:Number = 0;
			for (var item:* in _itemsAssoc)
				++count;
			return count;
		}
		protected function getItemAssoc(key:*):*
		{
			return _itemsAssoc[key];
		}
		protected function setItemAssoc(key:*, value:*):void
		{
			_itemsAssoc[key] = value;
		}
		
		protected function get itemCount():Number
		{
			return _items.length;
		}
		protected function getItem(idx:Number):*
		{
			return _items[idx];
		}
		protected function addItem(item:*):void
		{
			_items.push(item);
		}
	}
}