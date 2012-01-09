package managers.resources 
{
	import managers.ResourceManager;
	/**
	 * ...
	 * @author Jed Lang
	 */
	public class Resource_Iron extends Resource 
	{
		public function Resource_Iron(id:int=-1) 
		{
			super(ResourceManager.RESOURCETYPE_IRON, 0, id);
		}
	}
}