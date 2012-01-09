package
{
	import com.cinder.common.config.Configuration;
	import com.cinder.common.effects.light.Darkness;
	import com.junkbyte.console.Cc;
	import com.junkbyte.console.Console;
	import com.junkbyte.console.view.ConsolePanel;
	import com.junkbyte.console.view.GraphingPanel;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import managers.CentralUpdater;
	import managers.CityManager;
	import managers.QuestManager;
	import managers.ResourceManager;
	import org.flixel.*;

	[SWF(width="640", height="480", backgroundColor="#000000")]
	[Frame(factoryClass="Preloader")]
	public class Pilot extends FlxGame
	{
		//Graphics
		[Embed(source = "data/gfx/interface/popup.png")]
		public static const POPUPIMG_PNG:Class;
		
		
		public static var scale:Number = 1;
		
		
		private var _updater:CentralUpdater;
		
		
		public function Pilot()
		{
			super(640 / scale, 480 / scale, PrerollerState, scale, 60, 60);
			forceDebugger = true;
			debuggerEnabled = false;
			_updater = new CentralUpdater();
			_updater.registerManager(QuestManager.instance);
		}
		
		override protected function create(FlashEvent:Event):void 
		{
			super.create(FlashEvent);
			
			//Singletons
			//ResourceManager is lazy initialized
			CityManager.instance.widthInTiles = 11;
			CityManager.instance.heightInTiles = 11;
			Darkness.Init(this);
		}
		
		override protected function update():void 
		{
			_updater.update();
			super.update();
		}
	}
}

