package com.visualgoodness.intermark.utils {
	/**
	 * ...
	 * @author Ben Roth
	 */
	
	import com.visualgoodness.intermark.dataObjects.DealerDO
	import com.visualgoodness.intermark.dataObjects.IncentivesDO;
	public class intermarkXmlParser{
		
		public function intermarkXmlParser() {
			
		}

		public function parseDealer(data:XMLList):Array {
			
			var dealers = new Array();
			var dObj:DealerDO = new DealerDO();
			for each (var dealer:XML in data.dealer) {
				var dealerAttribs = dealer.attributes()
				for each (var attrib:XML in dealerAttribs) {
					try{ dObj[attrib.name().toString()] = attrib } catch(e){}
				}
				dealers.push(dObj);
			}
			trace("::parsed dealers XML::");
			return dealers;
		}
	
		
		
		public function parseIncentives(data:XMLList):Array {
			var incentives:Array = new Array();
			for each (var tda:XML in data.tda) {
				var tdaAttribs = tda.attributes();
				for each (var incentive:XML in tda.incentive) {
					var iObj:IncentivesDO = new IncentivesDO();
					
					for each (var tdaAttrib in tdaAttribs){
						try { iObj[tdaAttrib.name().toString()] = tdaAttrib } catch (e) { }
					}	
					var incentiveAttribs = incentive.attributes()
					for each (var attrib:XML in incentiveAttribs) {
						iObj[attrib.name().toString()] = attrib 
					}
					var incentiveChildren = incentive.children(); 
					var applicableModelYearArr:Array = new Array("");
					var excludedModelArr:Array = new Array();
					var aprDataArr:Array = new Array();
					for each (var child:XML in incentiveChildren) {
						if (child.name() == "applicableModelYear") {
							applicableModelYearArr.push(child)
						}
						if (child.name() == "excludedModel") {
							excludedModelArr.push(child);
						}
						if (child.name() == "aprData") {
							var aprCount:uint = 0;
							for each (var aprChild:XML in child) {
								var aprObj:Object = { rate:"", term:"" } 
								aprObj.rate = aprChild.apr[aprCount].attribute("rate");
								aprObj.term = aprChild.apr[aprCount].attribute("term");
								aprDataArr.push(aprObj);
								aprCount ++;
							}
						}
						if (child.name() == "restrictionText") {
							iObj.restrictionText = child;
						}
						if (child.name() == "description") {
							iObj.description = child;
						}
						if (child.name() == "disclaimer") {
							iObj.disclaimer = child;
						}
					}
					iObj.applicableModel = applicableModelYearArr;
					iObj.excludedModel = excludedModelArr;
					iObj.aprData = aprDataArr
					incentives.push(iObj);
				}
				
			}
			trace("::parsed incentives XML::");
			if (incentives.length == 0) trace("::: There dont seem to be any incentives for this location :::");
			return incentives;
		}
		
		
	}

}