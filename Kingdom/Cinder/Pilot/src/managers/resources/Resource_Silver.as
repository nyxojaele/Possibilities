package managers.resources 
{
	import managers.ResourceManager;
	/**
	 * ...
	 * @author Jed Lang
	 */
	public class Resource_Silver extends Resource 
	{
		public function Resource_Silver(id:int=-1) 
		{
			super(ResourceManager.RESOURCETYPE_SILVER, 0, id);
		}
	}
}