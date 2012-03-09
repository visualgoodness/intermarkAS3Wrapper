package com.visualgoodness 
{
	import com.visualgoodness.models.Logger;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.external.ExternalInterface;
	import flash.system.Security;
	import flash.utils.getDefinitionByName;
	import com.visualgoodness.views.LandingclipView;
	import com.visualgoodness.models.QueryString;
	

	
	/**
	 * ...
	 * @author Ben Roth
	 */
	
	public class Main extends MovieClip 
	{
		private var debugging:Boolean = true;
		private var pageURL:String;
		private var type:String;
		private var activeView:LandingclipView;
		private var logger:Logger = new Logger();
		
		public function Main() 
		{	
			var urlData:Object;
			Security.allowDomain("*")
			
			//parse the Variables from the URL query string of the current page into an object
			//the url should contain the "type" and "zip" variables
			var queryString:QueryString = new QueryString();
			
			try {
				//if the urldata is good
				urlData = { type : initialCaps(queryString.parameters.track), zip : queryString.parameters.zipcode };
				//set the current view based on the type var
				setView(urlData.type);
			} catch (e) {
				// if the urldata is bad
				logger.log('no url parameters found, using default values');
				urlData = { type : "undefined" , zip : "undefined" };
				
				//the middle view is used as a default fallback
				setView("Middle");
			}
			
			
			
			// get the incentives
			activeView.loadIncentives(urlData.zip);
		
			
			
			logger.log('zipcode: ' + urlData.zip);
			logger.log('track: ' +urlData.type);
			
			
			
		
		}
		
	
	
	
		
		private function setView(viewName:String):void {
			try {
				// add the appropriate view
				// the 'viewName' string being passed in should correlate directly with the linkage name of the appropraite movie clip in the FLA (Buy, Lease, or Middle)
				var Landing:Class = getDefinitionByName(viewName) as Class
				activeView = new Landing() as LandingclipView;
				addChild(activeView);
			} catch (e:Error) {
				urlError();
				logger.log("Couldn't create the view class. Check that the url contains a string which matches an available class definition");
				throw e;
			}
			
		}
		
		
		private function urlError() {
			addChild(new Middle());
		}
		
		
		
		//_________________ utils ______________________________________
		
		// check that Javascript is available (used mainly to check if testing in the IDE or the browser)
		public function JSAvailable():Boolean {
			if (ExternalInterface.available) {
				if (ExternalInterface.call("Function(\"return true;\")")) {
					return true;
				}
			}           
			return false;
		}
		
		// formats a string so that the first letter is uppercase and the rest of the string is lowercase
		private function initialCaps(type:String):String {
			var firstChar:String = type.substr(0, 1); 
			var restOfString:String = type.substr(1, type.length); 
			var viewName:String = firstChar.toUpperCase() + restOfString.toLowerCase();
			return viewName;
		}
		
		
		
		
	}

}


//http://qa.services.tmsbuyatoyota.com/dealers.asmx
//http://qa.services.tmsbuyatoyota.com/zipcodeIncentives.asmx


/*Buy: "http://tristate.buyatoyota.com/AdLandingSpecialFlash/BVL/BVLBUY"
Lease: "http://tristate.buyatoyota.com/AdLandingSpecialFlash/BVL/BVLLEASE"
Middle: "http://tristate.buyatoyota.com/AdLandingSpecialFlash/BVL/BVLMIDDLE"*/