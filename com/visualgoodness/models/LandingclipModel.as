package com.visualgoodness.models 
{
	/**
	 * ...
	 * @author Ben Roth
	 */
	
	import com.visualgoodness.intermark.IntermarkAPI;
	import com.visualgoodness.intermark.events.IntermarkEvents;
	import com.visualgoodness.intermark.dataObjects.DealerDO
	import com.visualgoodness.intermark.dataObjects.IncentivesDO
	import com.visualgoodness.views.LandingclipView;
	import com.visualgoodness.CustomEvent;
	import flash.display.Sprite;
	import flash.events.HTTPStatusEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.system.Security;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.external.ExternalInterface;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;
	
	
	public class LandingclipModel extends EventDispatcher
	{
		private var iMark:IntermarkAPI = new IntermarkAPI(false);
		private var view:LandingclipView;
		private var incentives:Array = new Array();
		private var carsLoadedCount:uint = 0;
		private var server:String;
		private var carCache:Dictionary = new Dictionary();
		private var lc:LoaderContext;
		private var carLoaders:Array 
		private var logger:Logger = new Logger();
		
		public function LandingclipModel(theView:LandingclipView) {
			
			Security.allowDomain( '*' );			
			Security.allowInsecureDomain( '*' );			
			view = theView;
			carLoaders = new Array();
			lc = new LoaderContext();
			server = "http://buy-vs-lease.com/images/"
			//loadDealers("19707", "2");	
			iMark.addEventListener(IntermarkEvents.INCENTIVE_READY, incentivesLoaded);
			iMark.addEventListener(IntermarkEvents.INCENTIVE_LOADING, incetiveLoading);
			
		}
		

		//handle loading graphics
		private function incetiveLoading(e:IntermarkEvents):void {
			logger.log(e.data.bytesLoaded);
			var loadingObj:Object = { bytesLoaded: e.data.bytesLoaded, bytesTotal:e.data.bytesTotal };
			view._preloader.text = (e.data.bytesLoaded / e.data.bytesTotal) * 100;
			dispatchEvent(new CustomEvent(CustomEvent.INCENTIVES_LOADING, loadingObj));
		}
		
		private function incentivesLoaded(e:IntermarkEvents):void {
			var incentiveCount:uint = 0;
			if((e.data as Object).length > 0){
				for each(var i:IncentivesDO in e.data) {
					trace(getQualifiedClassName(view));
					
					// react differently depending on which View this is
					switch(getQualifiedClassName(view)) {
						case "Lease":
							if (i.includesLease ==  null) incentives.push(i);
							break;
						case "Buy":
							if (i.includesLease == "NO") {
								if (i.cashBack == null) {
									
									for each (var j:IncentivesDO in e.data) {
										if (j.cashBack != null) {		
											if (i.seriesName == j.seriesName) {
												i.cashBack = j.cashBack;
												incentives.push(i);
												break;
											}
										}
									}
								} else {
									//incentives.push(i);
								}
							} 
							break;
						case "Middle":
							if (i.includesLease == "NO") {
								if(i.cashBack == null){
									for each (var k:IncentivesDO in e.data) {
										if (k.cashBack != null) {		
											if (i.seriesName == k.seriesName) {
												i.cashBack = k.cashBack;
												incentives.push(i);
												break;
											}
										}
									}
								}
							} else {
								//incentives.push(i);
							}
						break;
					}
					
					if (incentives.length >= 3) {
						loadCar(incentives[0].seriesName);
						break;
					} 
				}
			} else {
				// intermark api returned no data for this zipcode
				logger.log('no data');
				dispatchEvent(new CustomEvent(CustomEvent.INCENTIVES_LOADED, incentives));
			}
		}

		
		public function loadCar(carName:String) {
			switch(carName) {
				case "Prius 3rd Gen":
					trace('changed carname from', carName);
					carName = "prius"
					break;
			}
			
			var url:String = server + carName.toLowerCase() + '.png';

			logger.log('loading image from ' + url);
			var carLoader:Loader = new Loader() as Loader
			trace(carLoader.load, typeof carLoader);
			carLoader.load(new URLRequest(url),lc);
			carLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, carLoaded);
			carLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, carLoadFail);
			carLoaders.push(carLoader);
			
			
			
            //carLoader.contentLoaderInfo.addEventListener(Event.OPEN, logger.log);
            //carLoader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, logger.log);
            //carLoader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, logger.log);
            //carLoader.contentLoaderInfo.addEventListener(HTTPStatusEvent.HTTP_STATUS, logger.log);

		}
		
		
		private function carLoaded(e:Event = null, cachedCar:DisplayObject = null ) {
			var s:Sprite = new Sprite();
			if (e) {
				incentives[carsLoadedCount].carImage = s.addChild(carLoaders[carsLoadedCount]) as DisplayObject;
			} else {
				//car wasnt cached and couldnt be loaded, draw a blank box so the deals space properly
				var bmpData:BitmapData = new BitmapData(125, 90, true, 0x000000);
				var bmp:Bitmap = new Bitmap(bmpData);
				s.addChild(bmp);
				incentives[carsLoadedCount].carImage = s as DisplayObject;
			}
			logger.log('load successful');
			carCache[carLoaders[carsLoadedCount].contentLoaderInfo.url] = incentives[carsLoadedCount].carImage;
			carsLoadedCount ++ ;
			if ( carsLoadedCount >= incentives.length) {
				//logger.log('all cars loaded, show');
				dispatchEvent(new CustomEvent(CustomEvent.INCENTIVES_LOADED, incentives));
			} else {
				//logger.log('load next car');
				loadCar(incentives[carsLoadedCount].seriesName);
			}
			
		}
		
		
		private function carLoadFail(e:Event) {
			var logString:String = "IO error while loading the car image"
			logger.log(logString);
			carLoaded();
		}

		
		//_____________ public methods ____________________
		public function loadIncentives(zip:String, model:String):void {
			iMark.loadIncentives(zip, model);
			
		}


	}

}