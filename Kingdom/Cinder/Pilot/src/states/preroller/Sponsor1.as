package states.preroller 
{
	/**
	 * ...
	 * @author Jed Lang
	 */
	public class Sponsor1 extends Sponsor 
	{
		[Embed(source = "../../data/gfx/sponsors/sponsor1.png")]
		private static const IMG_PNG:Class;
		
		
		public function Sponsor1() 
		{
			super(IMG_PNG, 1);
		}
		
	}

}