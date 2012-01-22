package states.map 
{
	import com.cinder.common.ui.FlxProgressBar;
	import org.flixel.FlxGroup;
	import states.FlxButtonTag;
	
	/**
	 * ...
	 * @author Jed Lang
	 */
	public class FlxQuestButton extends FlxGroup 
	{
		private var _button:FlxButtonTag;
		private var _progress:FlxProgressBar;
		
		public function set minValue(value:Number):void { _progress.minValue = value; }
		public function set maxValue(value:Number):void { _progress.maxValue = value; }
		public function set currentvalue(value:Number):void { _progress.currentValue = value; }
		public function get y():Number { return _button.y; }
		
		
		public function FlxQuestButton(x:Number, y:Number, text:String, callback:Function, tag:*) 
		{
			_button = new FlxButtonTag(x, y, text, callback, tag);
			_progress = new FlxProgressBar(x + 80, y);
			add(_button);
			add(_progress);
		}
	}
}