package managers.resources 
{
	import managers.ResourceManager;
	/**
	 * ...
	 * @author Jed Lang
	 */
	public class Resource_Food extends Resource 
	{
		public function Resource_Food(id:int=-1) 
		{
			super(ResourceManager.RESOURCETYPE_FOOD, 0, id);
		}
	}
}