package states.play.actors 
{
	import com.junkbyte.console.Cc;
	import flash.display.Graphics;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import managers.city.GridPlacement;
	import managers.CityManager;
	import org.flixel.FlxBasic;
	import org.flixel.FlxG;
	import org.flixel.FlxGroup;
	import org.flixel.FlxPoint;
	import org.flixel.FlxRect;
	import org.flixel.FlxSprite;
	import org.flixel.FlxTilemap;
	import states.play.actors.playgrid.*;
	import managers.city.buildings.Building;
	import states.play.WorldView;
	import states.play.WorldView;
	
	/**
	 * ...
	 * @author Jed Lang
	 */
	public class PlayGrid extends FlxGroup implements IEventDispatcher
	{		
		//Other Constants
		private static const tileSpacing:Number = 3;
		
		
		private var _width:Number = 0;
		private var _height:Number = 0;
		private var _drawLines:Boolean;
		public function set drawLines(value:Boolean):void
		{
			_drawLines = value;
			if (value)
			{
				_lines.generateIfNull(tileSpacing, _tileSize, CityManager.instance.widthInTiles, CityManager.instance.heightInTiles, new FlxRect(_leftPadding, _topPadding, _rightPadding, _bottomPadding));
				add(_lines);
			}
			else
				remove(_lines);
		}
		public var hiliteBlankCells:FlxPoint;	//Dimensions of blank cells to hilite under the mouse cursor (used for placing buildings)
		private var _leftPadding:Number = 0;
		public function set leftPadding(value:Number):void
		{
			if (value != _leftPadding)
			{
				_leftPadding = value;
				calculateDimensions();
				if (_drawLines)
					_lines.forceGenerate(tileSpacing, _tileSize, CityManager.instance.widthInTiles, CityManager.instance.heightInTiles, new FlxRect(_leftPadding, _topPadding, _rightPadding, _bottomPadding));
			}
		}
		private var _rightPadding:Number = 0;
		public function set rightPadding(value:Number):void
		{
			if (value != _rightPadding)
			{
				_rightPadding = value;
				calculateDimensions();
				if (_drawLines)
					_lines.forceGenerate(tileSpacing, _tileSize, CityManager.instance.widthInTiles, CityManager.instance.heightInTiles, new FlxRect(_leftPadding, _topPadding, _rightPadding, _bottomPadding));
			}
		}
		private var _topPadding:Number = 0;
		public function set topPadding(value:Number):void
		{
			if (value != _topPadding)
			{
				_topPadding = value;
				calculateDimensions();
				if (_drawLines)
					_lines.forceGenerate(tileSpacing, _tileSize, CityManager.instance.widthInTiles, CityManager.instance.heightInTiles, new FlxRect(_leftPadding, _topPadding, _rightPadding, _bottomPadding));
			}
		}
		private var _bottomPadding:Number = 0;
		public function set bottomPadding(value:Number):void
		{
			if (value != _bottomPadding)
			{
				_bottomPadding = value;
				calculateDimensions();
				if (_drawLines)
					_lines.forceGenerate(tileSpacing, _tileSize, CityManager.instance.widthInTiles, CityManager.instance.heightInTiles, new FlxRect(_leftPadding, _topPadding, _rightPadding, _bottomPadding));
			}
		}
		
		private var _lines:PlayGridLines;
		private var _tileSize:Number;	//Numeric value representing the dimension of a tile on the X or Y plane.  Maybe not equate to pixels
		
		private var _hilitePlacement:GridPlacement;
		public function get hilitePlacement():GridPlacement { return _hilitePlacement; }
		
		private var _placementAtMouse:GridPlacement;
		public function get placementAtMouse():GridPlacement { return _placementAtMouse; }
		
		
		private var _worldView:WorldView;
		private var _eventDispatcher:EventDispatcher;
		
		
		public function PlayGrid(x:Number, y:Number, tileSize:Number, worldView:WorldView)
		{
			super();
			_worldView = worldView;
			_eventDispatcher = new EventDispatcher(this);
			
			drawLines = false;
			hiliteBlankCells = null;
			
			_lines = new PlayGridLines();
			add(_lines);
			_tileSize = tileSize;
			
			_hilitePlacement = null;
			_placementAtMouse = new GridPlacement(0, 0);
			
			calculateDimensions();
		}
		public function initBuildings():void
		{
			//Get existing buildings drawing
			var buildings:Array = CityManager.instance.getAllBuildingsForPlayGrid();
			for each (var placement:GridPlacement in buildings)
			{
				placement.pushCoordsToBuilding(_tileSize, tileSpacing, _leftPadding + _width / 2, _topPadding);
				add(placement.building.graphics);
			}
		}
		
		private function calculateDimensions():void 
		{
			//This is the same calculation used in PlayGridLines.generate()
			var wAndH:Number = (CityManager.instance.widthInTiles + CityManager.instance.heightInTiles) / 2;
			var w:Number = (_tileSize + tileSpacing) * wAndH;
			var h:Number = (_tileSize + tileSpacing) * wAndH / 2;	//Half tile AND spacing on Y
			
			_width = w + _leftPadding + _rightPadding;
			_height = h + _topPadding + _bottomPadding;
		}
		
		
		//Returns the tile coordinates of a specific point on the screen, or null if there is no tile
		private function screenToTileCoords(screenX:Number, screenY:Number):FlxPoint
		{
			var tileAndSpacing:Number = (_tileSize + tileSpacing) / 2;
			
			var localX:Number = screenX - _lines.x - _lines.width / 2 - _leftPadding;
			var localY:Number = screenY - _lines.y - _topPadding;
			
			var ty:Number = (2 * localY - localX) / 2 - tileAndSpacing / 2;
			var tx:Number = localX + ty;
			var tileY:Number = Math.round(ty / tileAndSpacing);
			var tileX:Number = Math.round(tx / tileAndSpacing);
			
			if (tileX < 0 ||
				tileX >= CityManager.instance.widthInTiles ||
				tileY < 0 ||
				tileY >= CityManager.instance.heightInTiles)
			{
				tileY = -1;
			}
			
			if (tileX == -1 ||
				tileY == -1)
				return null;
			else
				return new FlxPoint(tileX, tileY);
		}
		//Returns the tile coordinates of the mouse location, or null if there is no tile
		private function mouseToTileCoords():FlxPoint
		{
			return screenToTileCoords(FlxG.mouse.screenX, FlxG.mouse.screenY);
		}
		
		
		public override function update():void
		{
			//Update placementAtMouse
			var tileChanged:Boolean = false;
			var mouseCoords:FlxPoint = mouseToTileCoords();
			if (mouseCoords)
			{
				//Mouse is over the PlayGrid
				//Note that short circuit evaluation prevents a null reference exception here
				if (!_placementAtMouse ||							//Mouse was not over the PlayGrid previously
					_placementAtMouse.coordsInTiles != mouseCoords)	//Mouse was over the PlayGrid previously, and it was a different tile
				{
					_placementAtMouse = new GridPlacement(mouseCoords.x, mouseCoords.y);
					tileChanged = true;
					
				}
				//Otherwise, mouse is over the PlayGrid, and it was previously, but it was the same tile as now
			}
			else if (_placementAtMouse != null)
			{
				//Mouse is not over the PlayGrid, but was previously
				_placementAtMouse = null;
				tileChanged = true;
			}
			//Otherwise, mouse is not over the PlayGrid, and wasn't previously
			
			
			//Update hilite
			var hiliteChanged:Boolean = false;
			if (_placementAtMouse)
			{
				//Mouse is over the PlayGrid
				var collisionPlacement:GridPlacement = getPlacementCollidingWith(_placementAtMouse);	//Potentially returns null if mouse isn't over an existing GridPlacement
				if (hiliteBlankCells)	//This takes priority since when placing buildings we don't want to hilite existing ones
				{
					if (!GridPlacement.equals(_hilitePlacement, _placementAtMouse))	//So we can check coords & nullness all in one go
					{
						//Hilite blank cells under the mouse
						_hilitePlacement = _placementAtMouse;
						
						//Only the placement at mouse was created without placing a building, so it's not positioned correctly.
						_hilitePlacement.pushCoordsToBuilding(_tileSize, tileSpacing, _leftPadding + _width / 2, _topPadding);
						hiliteChanged = true;
					}
					//Otherwise it's the same hilite as last time
				}
				else if (collisionPlacement)
				{
					//Something is hilited
					if (!GridPlacement.equals(_hilitePlacement, collisionPlacement, true))	//So we can check coords and nullness all in one go
					{
						_hilitePlacement = collisionPlacement;
						hiliteChanged = true;
					}
					//Otherwise it's the same hilite as last time
				}
				else if (_hilitePlacement)
				{
					//Nothing should be hilited, as the mouse is just hovering normally over PlayGrid
					_hilitePlacement = null;
					hiliteChanged = true;
				}
			}	
			else
			{
				//Mouse is not over the PlayGrid
				if (_hilitePlacement)
				{
					_hilitePlacement = null;
					hiliteChanged = true;
				}
			}
			
			
			//Wait until here to fire events, as some stuff may rely on other values having,
			//changed at the same time as the values that triggered these events.
			if (tileChanged)
				dispatchEvent(new PlayGridEvent(PlayGridEvent.PLAYGRID_PLACEMENTATMOUSE_CHANGED));
			if (hiliteChanged)
				dispatchEvent(new PlayGridEvent(PlayGridEvent.PLAYGRID_HILITEATMOUSE_CHANGED));
			
			//Children need updating
			super.update();
		}
		
		public override function draw():void 
		{
			super.draw();
			if (_hilitePlacement)
				_hilitePlacement.building.drawHilite();
		}
		override public function destroy():void 
		{
			//Remove building graphics first because we don't want them destroyed!
			for each (var member:FlxBasic in members)
			{
				if (!(member is PlayGridLines))	//Only PlayGridLines stays, as it gets recreated any time we recreate PlayGrid!
					remove(member);
			}
			super.destroy();
		}
		
		//Retrieves an existing building at a specific set of tile coordinates,
		//or null if there is no building there.
		public function getBuildingAt(placement:GridPlacement):Building
		{
			if (!placement)
				return null;
			
			var ret:GridPlacement = getPlacementCollidingWith(placement);
			if (!ret)
				return null;
			
			return ret.building;
		}
		//Retrieves an existing placement at a specific set of tile coordinates,
		//or null if there is no existing placement there.
		public function getPlacementCollidingWith(collidingWith:GridPlacement):GridPlacement
		{
			if (!collidingWith)
				return null;
			
			return CityManager.instance.checkBuildingAgainstOthers(collidingWith, GridPlacement.doesntCollide);
		}
		
		//Attempt to place the building at the requested location
		//Note that currently this function only supports rectagular building shapes!
		//Return whether placement was successful or not.
		public function placeBuilding(placement:GridPlacement, building:Building):Boolean
		{
			var tempPlacement:GridPlacement = new GridPlacement(placement.coordsInTiles.x, placement.coordsInTiles.y, building);
			
			//Check boundaries
			if (tempPlacement.rMostTile >= CityManager.instance.widthInTiles ||
				tempPlacement.bMostTile >= CityManager.instance.heightInTiles)
				return false;
			
			//Check collisions with existing buildings
			if (CityManager.instance.checkBuildingAgainstOthers(tempPlacement, GridPlacement.doesntCollide))
				return false;
			
			//If we got this far, there's no collisions
			var newPlacement:GridPlacement = CityManager.instance.placeBuildingAt(tempPlacement, placement);
			if (newPlacement == tempPlacement)
				add(building.graphics);
			newPlacement.pushCoordsToBuilding(_tileSize, tileSpacing, _leftPadding + _width / 2, _topPadding);
			//Re-sort for zlayers
			CityManager.instance.sortOn("zLayer", Array.NUMERIC);
			
			return true;
		}
		//Attempt to remove the building at the requested location
		//If no building was at that location, nothing happens
		public function removeBuildingAt(placement:GridPlacement):void
		{
			var buildingPlacement:GridPlacement = getPlacementCollidingWith(placement);
			if (buildingPlacement)
			{
				remove(buildingPlacement.building.graphics);
				CityManager.instance.removeBuilding(buildingPlacement);
			}
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