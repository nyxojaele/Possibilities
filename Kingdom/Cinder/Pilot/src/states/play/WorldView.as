package states.play
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import managers.city.GridPlacement;
	import org.flixel.FlxBasic;
	import org.flixel.FlxG;
	import org.flixel.FlxGroup;
	import org.flixel.FlxPoint;
	import org.flixel.FlxSprite;
	import org.flixel.FlxText;
	import states.play.actors.*;
	import states.play.actors.playgrid.PlayGridEvent;
	import managers.city.buildings.Building;
	import managers.city.buildings.Building_null;
	
	/**
	 * ...
	 * @author Jed Lang
	 */
	public class WorldView extends FlxGroup implements IEventDispatcher
	{
		private var _eventDispatcher:EventDispatcher;
		
		private var _actorsToRemove:Array;
		private var _removingBuilding:Boolean;			//Flags whether the next click will attempt to remove the building or not
		private var _heldBuilding:Building;				//The building that is currently "held" by the mouse (ie for placing a new building, or moving one)
		private var _lastPlacementPos:GridPlacement;	//The GridPlacement where a building was last placed
		private var _playGrid:PlayGrid;					//The area where buildings are placed
		
		
		public function WorldView() 
		{
			_eventDispatcher = new EventDispatcher(this);
			
			_actorsToRemove = [];
			_heldBuilding = null;
			_playGrid = new PlayGrid(0, 0, 32, this);
			_playGrid.topPadding = 150;
			_playGrid.drawLines = true;
			_playGrid.initBuildings();
			_playGrid.addEventListener(PlayGridEvent.PLAYGRID_HILITEATMOUSE_CHANGED, hiliteAtMouse_Changed, false, 0, true);
			addActor(_playGrid);
		}
		private function hiliteAtMouse_Changed(e:Event):void 
		{
			//If hilite is populated, either the mouse is over a building, or it's been told to hilite blank tiles
			//It'll only be told to hilite blank tiles when placing a building, so we take that into consideration
			if (_playGrid.hilitePlacement)
			{
				if (_playGrid.hilitePlacement.building == Building_null.instance)
				{
					//We must be placing a building
				}
				else
				{
					//We must have the mouse over a building
					dispatchEvent(new WorldViewEvent(WorldViewEvent.WORLD_BUILDING_HILITED, _playGrid.hilitePlacement.building));
				}
			}
			else
				//Reset
				dispatchEvent(new WorldViewEvent(WorldViewEvent.WORLD_BUILDING_HILITED, Building_null.instance));
		}
		
		//Centralized function for adding actors in case other steps get added
		private function addActor(actor:FlxBasic):void
		{
			add(actor);
		}
		
		
		//Set a specific building as being "held" by the mouse cursor, for placement/movement
		public function holdBuilding(building:Building):void
		{
			_heldBuilding = building;
			_playGrid.hiliteBlankCells = building ? new FlxPoint(building.wInTiles, building.hInTiles) : null;
			if (_heldBuilding)
				//Only non-null, as all null cases are handled differently, elsewhere
				dispatchEvent(new WorldViewEvent(WorldViewEvent.WORLD_BUILDING_HOLDING, _heldBuilding));
		}
		//Cancel the last placed building, typically because resources were available when first selected, but not when placed
		public function cancelLastPlacedBuilding():void
		{
			_playGrid.removeBuildingAt(_lastPlacementPos);
		}
		//Remove the next building that gets clicked
		public function removeNextClickedBuilding():void
		{
			_removingBuilding = true;
		}
		
		
		public override function update():void
		{
			//Check for clicks
			if (FlxG.mouse.justPressed())
			{
				if (_removingBuilding)
				{
					if (_playGrid.placementAtMouse)
					{
						//Player clicked in the PlayGrid
						_playGrid.removeBuildingAt(_playGrid.placementAtMouse);
					}
					else
					{
						//Building could not be removed
						//TODO: Play a sound?
					}
					_removingBuilding = false;
				}
				else if (_heldBuilding)
				{
					//Player has previously clicking on a "new building" button, or clicked on an existing building in PlayGrid
					if (_playGrid.placementAtMouse)
					{
						//Player clicked in the PlayGrid
						if (_playGrid.placeBuilding(_playGrid.placementAtMouse, _heldBuilding))	//If successful, fires the CITY_BUILDING_PLACED event
						{
							//Building placed successfully
							_lastPlacementPos = _playGrid.placementAtMouse;
							var placedBuilding:Building = _heldBuilding;
							holdBuilding(null);
							//Immediately fire the hilite event too, as the building is now hilited (HiliteAtMouse_Changed doesn't fire because the hilite doesn't change!)
							dispatchEvent(new WorldViewEvent(WorldViewEvent.WORLD_BUILDING_HILITED, placedBuilding));
						}
						else
						{
							//Building could not be placed
							//TODO: Play sound?
						}
					}
					else
					{
						//Player clicked outside the PlayGrid, cancel
						var cancelBuilding:Building = _heldBuilding;
						holdBuilding(null);
						dispatchEvent(new WorldViewEvent(WorldViewEvent.WORLD_BUILDING_CANCELLED, cancelBuilding));
					}
				}
				else
				{
					//Player may be attempting to click on a building in PlayGrid
					holdBuilding(_playGrid.getBuildingAt(_playGrid.placementAtMouse));
				}
			}
			
			super.update();	//Update all the actors
		}
		
		
		/* INTERFACE flash.events.IEventDispatcher */
		public function dispatchEvent(event:Event):Boolean 
		{
			return _eventDispatcher.dispatchEvent(event);
		}
		public function hasEventListener(type:String):Boolean 
		{
			return _eventDispatcher.hasEventListener(type);
		}
		public function willTrigger(type:String):Boolean 
		{
			return _eventDispatcher.willTrigger(type);
		}
		public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void 
		{
			_eventDispatcher.removeEventListener(type, listener, useCapture);
		}
		public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void 
		{
			_eventDispatcher.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}
	}

}