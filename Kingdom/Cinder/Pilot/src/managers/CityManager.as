package managers 
{
	import com.junkbyte.console.Cc;
	import flash.net.URLVariables;
	import managers.city.CityEvent;
	import managers.city.GridPlacement;
	import managers.city.buildings.*
	/**
	 * ...
	 * @author ...
	 */
	public class CityManager extends Manager
	{
		private static var _instance:CityManager;
		public static function get instance():CityManager
		{
			if (!_instance) _instance = new CityManager();
			return _instance;
		}
		
		
		private static var buildingClasses:Array = [
			Building_Armoury,
			Building_Barber,
			Building_Barracks,
			Building_Blacksmith,
			Building_Castle,
			Building_Farm,
			Building_Fence,
			Building_MageTower,
			Building_Quarters,
			Building_TrainingGrounds,
			Building_Wall
			];
		public static function getBuildingClassByID(id:uint):Class
		{
			if (id >= buildingClasses.length)
				return null;
			return buildingClasses[id];
		}
		public static function getBuildingIDByClass(cls:Class):uint
		{
			return buildingClasses.indexOf(cls);
		}
		
		
		public var widthInTiles:Number = 0;
		public var heightInTiles:Number = 0;
		
		private var _buildings:Array;
		
		
		public function CityManager() 
		{
			super("buildings.php", requestReturn);
			_buildings = [];
		}
		
		
		//**********************************************************************
		//
		//                            SERVER DATA
		//
		//**********************************************************************
		protected override function getMemberClassByTypeId(typeId:uint):Class
		{
			return CityManager.getBuildingClassByID(typeId);
		}
		protected override function hydrateMemberWithServerData(member:ManagedItem, properties:Array):Boolean
		{
			if (properties.length != 5 ||
				isNaN(Number(properties[2])) ||
				isNaN(Number(properties[3])) ||
				isNaN(Number(properties[4])) ||
				!(member is Building))
				return false;
			
			var workingBuilding:Building = member as Building;
			workingBuilding.initFromServerData(Number(properties[4]));
			var workingPlacement:GridPlacement = new GridPlacement(Number(properties[2]), Number(properties[3]), workingBuilding);
			initBuilding(workingPlacement);	//This will fire an event for any listeners of CITY_BUILDING_PLACED
			return true;
		}
		private function initBuilding(placement:GridPlacement):void
		{
			_buildings.push(placement);
			dispatchEvent(new CityEvent(CityEvent.CITY_BUILDING_PLACED, placement.building));
		}
		
		private function sendBuildingPlaceRequest(workingPlacement:GridPlacement):void 
		{
			workingPlacement.building.setID(-Manager.requestID);	//Done before makeRequest so we get the value before it's incremented.
			var request:URLVariables = makeRequest("place");
			if (request)
			{
				request.classTypeID = CityManager.getBuildingIDByClass(Object(workingPlacement.building).constructor);
				request.toX = workingPlacement.coordsInTiles.x;
				request.toY = workingPlacement.coordsInTiles.y;
				request.health = workingPlacement.building.currentHealth;
				sendRequest(request);
			}
		}
		private function sendBuildingRemoveRequest(workingPlacement:GridPlacement):void
		{
			var request:URLVariables = makeRequest("remove");
			if (request)
			{
				request.id = workingPlacement.building.id;
				sendRequest(request);
			}
		}
		private function sendBuildingMoveRequest(fromPlacement:GridPlacement, toPlacement:GridPlacement):void 
		{
			var request:URLVariables = makeRequest("move");
			if (request)
			{
				request.id = fromPlacement.building.id;
				request.toX = toPlacement.coordsInTiles.x;
				request.toY = toPlacement.coordsInTiles.y;
				sendRequest(request);
			}
		}
		private function requestReturn(e:ManagerEvent):void
		{
			var vars:URLVariables = new URLVariables(e.data);
			if (vars.Action == "place")
			{
				//Find building by ID
				for each (var placement:GridPlacement in _buildings)
				{
					if (placement.building.id == -vars.RequestID)
					{
						placement.building.setID(vars.NewID);
						break;
					}
				}
			}
		}
		
		
		//**********************************************************************
		//
		//                         NORMAL FUNCTIONS
		//
		//**********************************************************************
		//Executes the passed in predicate between the passed in placement and all other placements in the city
		//Note that if the passed in placement exists within the city, the predicate is not executed between it and itself
		//This function returns the first placement in the city that the predicate fails against, or null if none fail
		public function checkBuildingAgainstOthers(placement:GridPlacement, predicate:Function):GridPlacement
		{
			for each (var b:GridPlacement in _buildings)
			{
				if (b.building == placement.building)
					continue;
				if (!predicate(placement, b))
					return b;
			}
			return null;
		}
		public function getAllBuildingsForPlayGrid():Array
		{
			return _buildings;
		}
		//Places placingPlacement at the location specified by placeAt, adding the GridPlacement to the buildings array as needed
		//Returns the GridPlacement of the building after it has been placed
		//Note that the returned value will be the same as placingPlacement if the building wasn't in the city beforehand
		public function placeBuildingAt(placingPlacement:GridPlacement, placeAt:GridPlacement):GridPlacement
		{
			var workingPlacement:GridPlacement;
			var foundPlacement:GridPlacement = getPlacementOfBuilding(placingPlacement.building);
			if (foundPlacement)
			{
				//placingPlacement.building exists within the city, and it's GridPlacement is foundPlacement
				//There is no guarantee that placingPlacement and foundPlacement are the same instance!
				workingPlacement = foundPlacement;
				sendBuildingMoveRequest(workingPlacement, placeAt);
				workingPlacement.coordsInTiles.copyFrom(placeAt.coordsInTiles);
				dispatchEvent(new CityEvent(CityEvent.CITY_BUILDING_MOVED, workingPlacement.building));
			}
			else
			{
				//placingPlacement.building doesn't exist within the city
				workingPlacement = placingPlacement;
				_buildings.push(placingPlacement);
				workingPlacement.coordsInTiles.copyFrom(placeAt.coordsInTiles);
				sendBuildingPlaceRequest(workingPlacement);
				dispatchEvent(new CityEvent(CityEvent.CITY_BUILDING_PLACED, workingPlacement.building));
			}
			return workingPlacement;
		}
		private function getPlacementOfBuilding(building:Building):GridPlacement
		{
			for each (var placement:GridPlacement in _buildings)
			{
				if (placement.building == building)
					return placement;
			}
			return null;
		}
		//After this function is called, it is expected that the building will no longer be in use, as it is destroyed
		public function removeBuilding(placement:GridPlacement, sendRequest:Boolean=true):void
		{
			if (sendRequest)
				sendBuildingRemoveRequest(placement);
			_buildings.splice(_buildings.indexOf(placement), 1);
			dispatchEvent(new CityEvent(CityEvent.CITY_BUILDING_REMOVED, placement.building));
			//This is done last so reactions to the event can still use the building before it's destroyed
			placement.building.destroy();
		}
		public function sortOn(property:String, type:uint):void
		{
			_buildings.sortOn(property, type);
		}
		public function hasBuilding(buildingCls:Class):Boolean
		{
			for each (var placement:GridPlacement in _buildings)
			{
				if (placement.building is buildingCls)
					return true;
			}
			return false;
		}
	}

}