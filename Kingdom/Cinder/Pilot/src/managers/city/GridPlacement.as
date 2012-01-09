package managers.city 
{
	import org.flixel.FlxPoint;
	import org.flixel.FlxSprite;
	import managers.city.buildings.Building;
	import managers.city.buildings.Building_null;
	/**
	 * ...
	 * @author Jed Lang
	 */
	//Note that this class currently assumes only rectangle shapes!
	public class GridPlacement
	{
		public static function equals(lhs:GridPlacement, rhs:GridPlacement, compareBuildings:Boolean=false):Boolean
		{
			if (!lhs || !rhs)
				return false;
			
			if (compareBuildings &&
				lhs.building != rhs.building)
				return false;
			
			return lhs.coordsInTiles.x == rhs.coordsInTiles.x &&
				   lhs.coordsInTiles.y == rhs.coordsInTiles.y;
		}
		public static function collides(lhs:GridPlacement, rhs:GridPlacement):Boolean
		{
			if (lhs.bMostTile < rhs.tMostTile) return false;	//This is above other
			if (lhs.tMostTile > rhs.bMostTile) return false;	//This is below other
			if (lhs.rMostTile < rhs.lMostTile) return false;	//This is left of other
			if (lhs.lMostTile > rhs.rMostTile) return false;	//This is right of other
			return true;
		}
		public static function doesntCollide(lhs:GridPlacement, rhs:GridPlacement):Boolean
		{
			return !collides(lhs, rhs);
		}
		
		
		public function get zLayer():Number { return coordsInTiles.x + coordsInTiles.y; }
		public var coordsInTiles:FlxPoint;
		
		public function get lMostTile():Number { return coordsInTiles.x; }
		public function get rMostTile():Number { return coordsInTiles.x + _building.wInTiles - 1; }
		public function get tMostTile():Number { return coordsInTiles.y; }
		public function get bMostTile():Number { return coordsInTiles.y + _building.hInTiles - 1; }
		
		private var _building:Building;
		public function get building():Building { return _building; }
		
		
		public function GridPlacement(x:Number, y:Number, building:Building=null)
		{
			if (building)
				_building = building;
			else
				_building = Building_null.instance;
				
			this.coordsInTiles = new FlxPoint(x, y);
		}
		
		
		public function pushCoordsToBuilding(tileSize:Number, tileSpacing:Number, xOffset:Number, yOffset:Number):void
		{
			_building.graphics.x = xOffset +																		//Offset of grid
								   (coordsInTiles.x - coordsInTiles.y) * (tileSize + tileSpacing) / 2 -				//Base tile pos
								   _building.graphics.width / 2 +													//Offset for graphic width
								   (_building.wInTiles - _building.hInTiles) / 2 * (tileSize + tileSpacing) / 2;	//Offset for graphic to center of tile
			
			_building.graphics.y = yOffset +																		//Offset of grid
								   (coordsInTiles.x + coordsInTiles.y) / 2 * (tileSize + tileSpacing) / 2 -			//Base tile pos
								   _building.graphics.height +														//Offset for graphic height
								   (_building.wInTiles + _building.hInTiles) / 2 * (tileSize + tileSpacing) / 2;	//Offset for graphic to bottom of tile
		}
	}

}