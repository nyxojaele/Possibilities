package managers 
{
	/**
	 * ...
	 * @author Jed Lang
	 */
	public class CentralUpdater
	{
		private var _managers:Array;
		
		
		public function CentralUpdater() 
		{
			_managers = [];
		}
		
		
		public function registerManager(manager:IUpdatingManager):void
		{
			_managers.push(manager);
		}
		
		public function update():void
		{
			for each (var manager:IUpdatingManager in _managers)
			{
				manager.update();
			}
		}
	}
}