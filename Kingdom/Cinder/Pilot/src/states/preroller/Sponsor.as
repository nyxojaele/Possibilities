package states.preroller 
{
	import org.flixel.FlxSprite;
	
	/**
	 * ...
	 * @author Jed Lang
	 */
	public class Sponsor extends FlxSprite 
	{
		protected var _displayTime:Number;	//In seconds
		public function get displayTime():Number { return _displayTime; }
		
		
		public function Sponsor(graphic:Class, displayTime:Number)
		{
			_displayTime = displayTime;
			super(0, 0, graphic);
		}
		
	}

}