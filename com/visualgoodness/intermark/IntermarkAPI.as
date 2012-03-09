package com.visualgoodness.intermark {
	/**
	 * ...
	 * @author Ben Roth
	 */
	
	 
	import com.visualgoodness.intermark.events.IntermarkEvents;
	import com.visualgoodness.intermark.utils.intermarkXmlParser;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.net.*
	import flash.events.*
	
	
	public class IntermarkAPI extends EventDispatcher{
		
		private var server:String;
		private var _dealers:Array 
		private var _dealersXML:XMLList
		private var _incentives:Array
		private var _incentivesXML:XMLList
		private var parser:intermarkXmlParser = new intermarkXmlParser();
		
		public function IntermarkAPI(useQaServer:Boolean = false) {
			if (useQaServer) {
				//didnt seem to be functioning last time I checked :(
				server = "http://qa.services.tmsbuyatoyota.com"
			} else {
				server = "http://services.tmsbuyatoyota.com"
			}
			
		}

		private function getDealer(zipCode:String, maxDealers:String) {
			var loader:URLLoader = new URLLoader();
			configureDealerListeners(loader);
			var url:String = server+"/dealers.asmx/getDealers";
			var request:URLRequest = new URLRequest(url);
			var variables:URLVariables = new URLVariables();
			variables.zipCode = zipCode;
			variables.maxDealers = maxDealers;
			request.data = variables;
			try {
				loader.load(request);
			} catch (error:Error) {
				trace("Unable to load requested document.");
			}
		}
		
		private function getIncentives(zipCode:String, series:String) {
			
			var loader:URLLoader = new URLLoader();
			configureIncentivesListeners(loader);
			var url:String =  server+"/zipcodeIncentives.asmx/getIncentives";
			var request:URLRequest = new URLRequest(url);
			var variables:URLVariables = new URLVariables();
			variables.zipCode = zipCode;
			variables.series = series;
			request.data = variables;
			try {
				loader.load(request);
			} catch (error:Error) {
				trace("Unable to load requested document.");
			}
		}
		
		//___________________________ dealer handlers _________________________________________________________
		private function configureDealerListeners(dispatcher:IEventDispatcher):void {
			dispatcher.addEventListener(Event.COMPLETE, dealerCompleteHandler);
			dispatcher.addEventListener(ProgressEvent.PROGRESS, dealerProgressHandler);
			dispatcher.addEventListener(SecurityErrorEvent.SECURITY_ERROR, dealerSecurityErrorHandler);
			dispatcher.addEventListener(IOErrorEvent.IO_ERROR, dealerIoErrorHandler);
		}

		private function dealerCompleteHandler(e:Event):void {
			trace("::Successfully retrieved dealer XML::");
			var loader:URLLoader = URLLoader(e.target);
			var d:XMLList = new XMLList(loader.data);
			_dealers = parser.parseDealer(d);
			_incentivesXML = d
			dispatchEvent(new IntermarkEvents(IntermarkEvents.DEALER_READY,_dealers));
		}


		private function dealerProgressHandler(event:ProgressEvent):void {
			dispatchEvent(new IntermarkEvents(IntermarkEvents.DEALER_LOADING, { bytesLoaded:event.bytesLoaded, bytesTotal:event.bytesTotal } ));
		}

		private function dealerSecurityErrorHandler(event:SecurityErrorEvent):void {
			trace("securityErrorHandler: " + event);
		}


		private function dealerIoErrorHandler(event:IOErrorEvent):void {
			trace("ioErrorHandler: " + event);
		}
		
		
		//__________________________________incentives handlers____________________________________________________________
		
		private function configureIncentivesListeners(dispatcher:IEventDispatcher):void {
			dispatcher.addEventListener(Event.COMPLETE, incentivesCompleteHandler);
			dispatcher.addEventListener(ProgressEvent.PROGRESS, incentivesProgressHandler);
			dispatcher.addEventListener(SecurityErrorEvent.SECURITY_ERROR, incentivesSecurityErrorHandler);
			dispatcher.addEventListener(IOErrorEvent.IO_ERROR, incentivesIoErrorHandler);
		}

		private function incentivesCompleteHandler(e:Event):void {
			trace("::Successfully retrieved incentives XML::");
			var loader:URLLoader = URLLoader(e.target);
			var d:XMLList = new XMLList(loader.data);
			_incentives = parser.parseIncentives(d);
			_incentivesXML = d
			dispatchEvent(new IntermarkEvents(IntermarkEvents.INCENTIVE_READY, _incentives));
		}

		private function incentivesProgressHandler(event:ProgressEvent):void {
			dispatchEvent(new IntermarkEvents(IntermarkEvents.INCENTIVE_LOADING, { bytesLoaded:event.bytesLoaded, bytesTotal:event.bytesTotal } ));
		}

		private function incentivesSecurityErrorHandler(event:SecurityErrorEvent):void {
			trace("securityErrorHandler: " + event);
		}


		private function incentivesIoErrorHandler(event:IOErrorEvent):void {
			trace("ioErrorHandler: " + event);
		}

	
	
		//_______________________________________ public methods _________________________________________________________
		
		
		public function loadDealers(zipCode:String, maxDealers:String) {
			if (!_dealers) {
				getDealer(zipCode, maxDealers);
			}
		}
		public function loadIncentives(zipCode:String, carSeries:String = "") {
			if (!_incentives) {
				getIncentives(zipCode, carSeries);
			}
		}
		public function get dealers():Array { return _dealers; }
		
		public function get incentives():Array { return _incentives; }
		
		public function get dealersXML():XMLList { return _dealersXML; }
		
		public function get incentivesXML():XMLList { return _incentivesXML; }
		
	}
}


