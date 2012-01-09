package managers.minions 
{
	import flash.net.URLVariables;
	import managers.ManagedItem;
	
	/**
	 * ...
	 * @author Jed Lang
	 */
	public class Minion extends ManagedItem 
	{
		public static const FighterClassName:String = "Fighter";
		public static const MageClassName:String = "Mage";
		public static const GathererClassName:String = "Gatherer";
		public static const BuilderClassName:String = "Builder";
		
		public static const defaultFighterStat:Number = 1;
		public static const defaultMageStat:Number = 1;
		public static const defaultGathererStat:Number = 1;
		public static const defaultBuilderStat:Number = 1;
		
		
		public static function FromBuilder(name:String, sex:uint, builder:MinionBuilder):Minion
		{
			var minion:Minion = new Minion(-1, name, sex);
			minion._fighterStat = builder.fighterStat;
			minion._mageStat = builder.mageStat;
			minion._gathererStat = builder.gathererStat;
			minion._builderStat = builder.builderStat;
			return minion;
		}
		
		
		//Consts
		public static const MINION_SEXMALE:Number = 1;
		public static const MINION_SEXFEMALE:Number = 2;
		
		
		private var _name:String = "Unnamed";
		public function get name():String { return _name; }
		private var _sex:uint = MINION_SEXMALE;
		public function get sex():uint { return _sex; }
		
		public var questId:int = -1;
		
		protected var _fighterStat:Number = defaultFighterStat;
		public function get fighterStat():Number { return _fighterStat; }
		public function increaseFighterStatBy(value:Number):void { _fighterStat += value; }
		protected var _mageStat:Number = defaultMageStat;
		public function get mageStat():Number { return _mageStat; }
		public function increaseMageStatBy(value:Number):void { _mageStat += value; }
		protected var _gathererStat:Number = defaultGathererStat;
		public function get gathererStat():Number { return _gathererStat; }
		public function increaseGathererStatBy(value:Number):void { _gathererStat += value; }
		protected var _builderStat:Number = defaultBuilderStat;
		public function get builderStat():Number { return _builderStat; }
		public function increaseBuilderStatBy(value:Number):void { _builderStat += value; }
		public function get minionClass():String
		{
			var max:Number = Math.max(_fighterStat, _mageStat, _gathererStat, _builderStat);
			if (max == _fighterStat)
				return FighterClassName;
			else if (max == _mageStat)
				return MageClassName;
			else if (max == _gathererStat)
				return GathererClassName;
			else if (max == _builderStat)
				return BuilderClassName;
			//Unreachable
			return "";
		}
		
		
		public function Minion(id:Number, name:String="", sex:uint=MINION_SEXMALE)
		{
			super(id);
			
			_name = name;
			_sex = sex;
		}
		
		
		//***********************************************************************
		//
		//                           SERVER DATA
		//
		//***********************************************************************
		public function initFromServerData(properties:Array):Boolean
		{
			if (properties.length != 9 ||
				//properties[2] is Name
				isNaN(Number(properties[3])) ||	//Sex
				isNaN(Number(properties[4])) ||	//FighterStat
				isNaN(Number(properties[5])) ||	//MageStat
				isNaN(Number(properties[6])) ||	//GathererStat
				isNaN(Number(properties[7])) ||	//BuilderStat
				isNaN(Number(properties[8])))	//QuestId
				return false;
			
			_name = properties[2];
			_sex = Number(properties[3]);
			_fighterStat = Number(properties[4]);
			_mageStat = Number(properties[5]);
			_gathererStat = Number(properties[6]);
			_builderStat = Number(properties[7]);
			questId = Number(properties[8]);
			return true;
		}
	}
}