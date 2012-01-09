package
{
	import com.junkbyte.console.Cc;
	import org.flixel.FlxG;
	import org.flixel.FlxSprite;
	import org.flixel.FlxState;
	import org.flixel.FlxTimer;
	import states.preroller.Sponsor;
	import states.preroller.Sponsor1;
	
	/**
	 * ...
	 * @author Jed Lang
	 */
	public class PrerollerState extends FlxState 
	{
		private var _sponsors:Array;	//Array of ISponsors
		private var _currentSponsorIndex:Number;
		
		private var _sponsorChangingTimer:FlxTimer
		
		
		override public function create():void 
		{
			Cc.log("*****Preroller State*****");
			super.create();
			
			_sponsors = [];
			_currentSponsorIndex = -1;
			_sponsorChangingTimer = new FlxTimer();
			
			populateSponsors();
			showNextSponsor();
		}
		
		private function populateSponsors():void
		{
			_sponsors.push(new Sponsor1());
		}
		
		//Attempts to show the next sponsor, if one is available.
		//If there isn't one available, it triggers the next game state.
		private function showNextSponsor():void
		{
			if (_currentSponsorIndex < _sponsors.length - 1)
			{
				//Still sponsors left
				++_currentSponsorIndex;
				var sponsorToShow:Sponsor = _sponsors[_currentSponsorIndex];
				sponsorToShow.x = FlxG.width / 2 - sponsorToShow.width / 2;
				sponsorToShow.y = FlxG.height / 2 - sponsorToShow.height / 2;
				
				add(sponsorToShow);
				_sponsorChangingTimer.start(sponsorToShow.displayTime, 1, sponsorComplete);
			}
			else
			{
				//Sponsors done, next state!
				FlxG.switchState(new MenuState);
			}
		}
		
		private function sponsorComplete(timer:FlxTimer):void 
		{
			//Remove existing
			var currentSponsor:Sponsor = _sponsors[_currentSponsorIndex];
			if (currentSponsor)
				remove(currentSponsor);
				
			showNextSponsor();
		}
	}
}