package managers.resources 
{
	import managers.ResourceManager;
	/**
	 * ...
	 * @author Jed Lang
	 */
	public class Resource_Gold extends Resource 
	{
		public function Resource_Gold(id:int=-1) 
		{
			super(ResourceManager.RESOURCETYPE_GOLD, 0, id);
		}
	}
}