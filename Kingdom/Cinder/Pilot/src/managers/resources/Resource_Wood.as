package managers.resources 
{
	import managers.ResourceManager;
	/**
	 * ...
	 * @author Jed Lang
	 */
	public class Resource_Wood extends Resource 
	{
		public function Resource_Wood(id:int=-1) 
		{
			super(ResourceManager.RESOURCETYPE_WOOD, 0, id);
		}
	}
}