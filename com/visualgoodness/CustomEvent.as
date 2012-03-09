package com.visualgoodness{
    import flash.events.Event;
	

    public class CustomEvent extends Event {
		public static const INCENTIVES_LOADED:String = "incentivesLoaded";
		public static const INCENTIVES_LOADING:String = "incentivesLoading";
		public static const CAR_LOADED:String = "carLoaded";
		public static const SHOW_CAR:String = "showCar";


		
		public var data:*;

		public function CustomEvent( type:String, data:* = null ) {
			super(type);
			this.data = data;
		}
    }
}