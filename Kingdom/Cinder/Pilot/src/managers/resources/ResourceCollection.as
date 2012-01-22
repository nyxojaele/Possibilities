package managers.resources 
{
	import com.junkbyte.console.Cc;
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	import managers.ItemCollection;
	import managers.ResourceManager;
	/**
	 * ...
	 * @author Jed Lang
	 */
	public class ResourceCollection extends ItemCollection
	{
		private static const _empty:ResourceCollection = new ResourceCollection();
		public static function get empty():ResourceCollection { return _empty; }
		
		
		public function ResourceCollection(gold:Number=0, wood:Number=0, food:Number=0) 
		{
			var g:Resource_Gold = new Resource_Gold();
			g.value = gold;
			var w:Resource_Wood = new Resource_Wood();
			w.value = wood;
			var f:Resource_Food = new Resource_Food();
			f.value = food;
			
			setItemAssoc(ResourceManager.RESOURCETYPE_GOLD, g);
			setItemAssoc(ResourceManager.RESOURCETYPE_WOOD, w);
			setItemAssoc(ResourceManager.RESOURCETYPE_FOOD, f);
		}
		
		
		//The following functions should abstract away the Resource classes used internally!
		//************************************************
		//
		//             RESOURCE ACCESS
		//
		//************************************************
		//This blows away IDs, types, etc.! Be careful when using this!
		public function initResource(resource:Resource):void
		{
			setItemAssoc(resource.type, resource);
		}
		public function getResourceID(resourceType:uint):int
		{
			return (getItemAssoc(resourceType) as Resource).id;
		}
		public function setResourceID(resourceType:uint, id:int):void
		{
			(getItemAssoc(resourceType) as Resource).setID(id);
		}
		
		public function getResource(resourceType:uint):Number
		{
			return (getItemAssoc(resourceType) as Resource).value;
		}
		public function setResource(resourceType:uint, value:Number):void
		{
			(getItemAssoc(resourceType) as Resource).value = value;
		}
	}
}