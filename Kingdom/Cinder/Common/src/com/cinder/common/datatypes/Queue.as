package com.cinder.common.datatypes 
{
	/**
	 * ...
	 * @author Jed Lang
	 */
	public class Queue 
	{
		private var q:Array = [];
		public var l:int = 0;
		
		
		public function Queue() 
		{ }
		
		
		//Push to the end of the queue
		public function push(data:*):void
		{
			q[q.length] = data;
			l++;
		}
		
		//Pop off the beginning of the queue
		public function pop():*
		{
			if (empty)
				return null;
			else
			{
				l--;
				return q.shift();
			}
		}
		
		//Peek at the beginning of the queue
		public function peek():*
		{
			return empty ? null : q[0];
		}
		
		public function get empty():Boolean
		{
			return l <= 0;
		}
	}
}