package com.visualgoodness.intermark.dataObjects {
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	/**
	 * ...
	 * @author Ben Roth
	 */
	public class IncentivesDO{
		
		public var tdaCode:String;
		public var tdaName:String;
		public var noIncentives:String;
		
		
		public var incentiveId:String
		public var incentiveType:String
		public var leaseMonthlyPayment:String
		public var leaseDueAtSigning:String
		public var leaseTerm:String
		public var queryname:String
		public var seriesName:String
		public var endDate:String
		public var cashBack:String
		public var includesLease:String
		
		public var applicableModel:Array
		public var excludedModel:Array
		// aprData is an array of apr objects. each apr object has a "rate" and "term" property.
		// example: aprData[0].rate and aprData[0].term
		public var aprData:Array
		public var restrictionText:String
		public var description:String
		public var disclaimer:String
		public var carImage:DisplayObject;

		public function IncentivesVO() {}
	}
}
