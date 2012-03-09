package com.visualgoodness.models 
{
	import flash.external.ExternalInterface;
	/**
	 * ...
	 * @author Ben Roth
	 */
	public class Logger 
	{
		
		public function Logger() 
		{
			
		}
		public function log(e:*):void {
			trace(e.toString());
			var logString:String = e.toString();
			ExternalInterface.call("console.log('"+logString+"')");
		}
		
	}

}