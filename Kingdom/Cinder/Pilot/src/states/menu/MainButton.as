package states.menu 
{
	import org.flixel.FlxButton;
	import org.flixel.FlxPoint;
	import org.flixel.FlxText;
	
	/**
	 * ...
	 * @author Jed Lang
	 */
	public class MainButton extends FlxButton 
	{
		[Embed(source = "../../data/gfx/interface/button.png")]
		private static var BUTTON_PNG:Class;
		
		public function MainButton(x:Number, y:Number, label:String, onClick:Function) 
		{
			super(x, y, label, onClick);
			loadGraphic(BUTTON_PNG, true, false, 160, 40);
			if (label != null)
			{
				this.label = new FlxText(0,0,160,label);
				this.label.setFormat(null,16,0x333333,"center");
				labelOffset = new FlxPoint(-1,10);
			}
		}
		
	}

}