package managers 
{
	/**
	 * ...
	 * @author Jed Lang
	 */
	public class ManagedItem 
	{
		//This should contain the ID for this instance, which is equal to p_ID in the DB
		protected var _id:int;
		public function get id():int { return _id; }
		public function setID(value:int):void { _id = value; }	//Deliberately not an accessor so it stands out and isn't accidentally used
		
		
		//All concrete implementations of this class must have a ctor that either accepts only id,
		//or has default values for the remaining parameters, in order for Managers to work properly.
		public function ManagedItem(id:uint=NaN)
		{
			_id = id;
		}
	}
}