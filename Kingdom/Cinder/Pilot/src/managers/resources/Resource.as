package managers.resources 
{
	import managers.ManagedItem;
	/**
	 * This class represents a resource type and a value pair
	 * @author Jed Lang
	 */
	public class Resource extends ManagedItem
	{
		protected var _type:uint;
		public function get type():uint { return _type; }
		public var value:int;
		
		
		public function Resource(type:uint, value:int=0, id:int=-1)
		{
			super(id);
			_type = type;
			this.value = value;
		}
	}
}