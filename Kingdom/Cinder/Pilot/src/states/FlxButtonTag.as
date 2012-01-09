package states 
{
	import com.junkbyte.console.Cc;
	import flash.events.MouseEvent;
	import org.flixel.FlxButton;
	
	/**
	 * The thing to note about FlxButtonTag is not only that it has a tag that can be used to
	 * hold only to any other instance, but also that that instance is passed into the
	 * Click handlers for the button
	 * @author Jed Lang
	 */
	public class FlxButtonTag extends FlxButton implements ITagHolder 
	{
		private var _tag:* = null;
		public function get tag():* { return _tag; }
		
		
		public function FlxButtonTag(x:Number, y:Number, label:String, onClick:Function, tag:*)
		{
			_tag = tag;
			super(x, y, label, onClick);
		}
		
		
		protected override function onMouseUp(event:MouseEvent):void
		{
			if(!exists || !visible || !active || (status != PRESSED))
				return;
			
			if (onUp != null)
				onUp(tag);
		}
	}
}