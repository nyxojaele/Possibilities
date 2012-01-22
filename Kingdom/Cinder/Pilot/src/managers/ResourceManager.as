package managers 
{
	import com.junkbyte.console.Cc;
	import flash.events.EventDispatcher;
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	import flash.utils.Dictionary;
	import managers.quests.IRewardSource;
	import managers.quests.IRewardTarget;
	import managers.resources.Resource;
	import managers.resources.Resource_Gold;
	import managers.resources.Resource_Wood;
	import managers.resources.Resource_Food;
	import managers.resources.ResourceCollection;
	import managers.resources.ResourceEvent;
	
	/**
	 * ...
	 * @author Jed Lang
	 */
	public class ResourceManager extends Manager implements IRewardTarget
	{
		//Resource Constants
		//Make sure that any changes to this list are reflected in the ctor of ResourceCollection!
		//Also, resources.php getResourceName(), checkResources() and trySpendResources()
		//Make sure the values applied are binary, as StreamState encodes these as a flagged enum for loading
		public static const RESOURCETYPE_WOOD:uint = 1;
		public static const RESOURCETYPE_GOLD:uint = 2;
		public static const RESOURCETYPE_FOOD:uint = 3;
		
		public static function getResourceName(resource:uint):String
		{
			switch (resource)
			{
				case RESOURCETYPE_WOOD: return "Wood";
				case RESOURCETYPE_GOLD: return "Gold";
				case RESOURCETYPE_FOOD: return "Food";
			}
			return "";
		}
		
		
		//Singleton
		private static var _instance:ResourceManager;
		public static function get instance():ResourceManager
		{
			if (!_instance) _instance = new ResourceManager();
			return _instance;
		}
		
		
		private var _resources:ResourceCollection;
		
		
		public function ResourceManager() 
		{
			super("resources.php");
			_resources = new ResourceCollection();
		}
		
		
		//**********************************************************************
		//
		//                             SERVER DATA
		//
		//**********************************************************************
		protected override function getMemberClassByTypeId(typeId:uint):Class
		{
			switch (typeId)
			{
				case RESOURCETYPE_WOOD: return Resource_Wood;
				case RESOURCETYPE_GOLD: return Resource_Gold;
				case RESOURCETYPE_FOOD: return Resource_Food;
			}
			return null;
		}
		protected override function hydrateMemberWithServerData(member:ManagedItem, properties:Array):Boolean
		{
			if (properties.length != 3 ||
				isNaN(Number(properties[2])) ||
				!(member is Resource))
				return false;
			
			var workingResource:Resource = member as Resource;
			workingResource.value = new Number(properties[2]);
			initResource(workingResource);	//This will fire an event for any listeners of RESOURCE_AMOUNTCHANGED events
			return true;
		}
		private function initResource(resource:Resource):void
		{
			_resources.initResource(resource);
			dispatchEvent(new ResourceEvent(ResourceEvent.RESOURCE_AMOUNTCHANGED, resource.type, resource.value));
		}
		
		private function sendResourceRequest(id:int, type:uint, value:Number):void
		{
			var request:URLVariables = makeRequest("set");
			if (request)
			{
				request.id = id;
				request.type = type;
				request.value = value;
				sendRequest(request);
			}
		}
		
		
		//**********************************************************************
		//
		//                         NORMAL FUNCTIONS
		//
		//**********************************************************************
		public function getResource(resource:uint):Number
		{
			return _resources.getResource(resource);
		}
		private function setResource(resource:uint, amount:Number):void
		{
			sendResourceRequest(_resources.getResourceID(resource), resource, amount);
			_resources.setResource(resource, amount);
			
			dispatchEvent(new ResourceEvent(ResourceEvent.RESOURCE_AMOUNTCHANGED, resource, amount));
		}
		public function checkResource(resource:uint, checkAgainst:Number):Boolean
		{
			return _resources.getResource(resource) >= checkAgainst;
		}
		public function addResource(resource:uint, amount:Number):void
		{
			var currentVal:Number = getResource(resource);
			if (amount == 0)	//Adding 0 does nothing
				return;
			
			var newVal:Number = currentVal + amount;
			
			sendResourceRequest(_resources.getResourceID(resource), resource, newVal);
			_resources.setResource(resource, newVal);
			
			dispatchEvent(new ResourceEvent(ResourceEvent.RESOURCE_AMOUNTCHANGED, resource, newVal));
		}
		public function removeResource(resource:uint, amount:Number):Boolean
		{
			if (checkResource(resource, amount))
			{
				addResource(resource, -amount);
				return true;
			}
			return false;
		}
		
		public function checkResources(checkAgainst:ResourceCollection):Boolean
		{
			return _resources.getResource(RESOURCETYPE_GOLD) >= checkAgainst.getResource(RESOURCETYPE_GOLD) &&
				_resources.getResource(RESOURCETYPE_WOOD) >= checkAgainst.getResource(RESOURCETYPE_WOOD) &&
				_resources.getResource(RESOURCETYPE_FOOD) >= checkAgainst.getResource(RESOURCETYPE_FOOD);
		}
		public function addResources(amount:ResourceCollection):void
		{
			addResource(RESOURCETYPE_GOLD, amount.getResource(RESOURCETYPE_GOLD));
			addResource(RESOURCETYPE_WOOD, amount.getResource(RESOURCETYPE_WOOD));
			addResource(RESOURCETYPE_FOOD, amount.getResource(RESOURCETYPE_FOOD));
		}
		public function removeResources(cost:ResourceCollection):Boolean
		{
			if (checkResources(cost))
			{
				removeResource(RESOURCETYPE_GOLD, cost.getResource(RESOURCETYPE_GOLD));
				removeResource(RESOURCETYPE_WOOD, cost.getResource(RESOURCETYPE_WOOD));
				removeResource(RESOURCETYPE_FOOD, cost.getResource(RESOURCETYPE_FOOD));
				return true;
			}
			return false;
		}
		
		
		/* INTERFACE managers.quests.IRewardTarget */
		public function applyReward(source:IRewardSource, applyToQuestId:uint):void 
		{
			if (source is ResourceCollection)
				addResources(source as ResourceCollection);
		}
	}
}