package com.cinder.common.config 
{
	/**
	 * ...
	 * @author Jed Lang
	 */
	public class Configuration 
	{
		//Singleton
		private static var _instance:Configuration = null;
		public static function get instance():Configuration
		{
			if (!_instance) _instance = new Configuration();
			return _instance;
		}
		
		
		public function get DebugMode():Boolean
		{
			return CONFIG::debug;
		}
		
		
		public function Configuration() 
		{ }
	}
}