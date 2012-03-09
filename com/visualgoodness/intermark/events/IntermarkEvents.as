package com.visualgoodness.intermark.events{
    import flash.events.Event;
	

    public class IntermarkEvents extends Event {
		public static const DEALER_READY:String = "dealerReady";
		public static const DEALER_LOADING:String = "dealerLoading";
		public static const INCENTIVE_READY:String = "incentiveReady";
		public static const INCENTIVE_LOADING:String = "incentiveLoading";

		
		public var data:*;

		public function IntermarkEvents( type:String, data:* = null ) {
			super(type);
			this.data = data;
		}
    }
}