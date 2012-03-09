package com.visualgoodness.views 
{
	import com.adobe.images.BitString;
	import com.visualgoodness.intermark.dataObjects.IncentivesDO;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import com.visualgoodness.models.LandingclipModel
	import com.visualgoodness.CustomEvent;
	import flash.display.SpreadMethod;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.text.Font;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	import flash.utils.Timer;
	
	import com.greensock.TweenLite;
	
	/**
	 * ...
	 * @author Ben Roth
	 */
	public class LandingclipView extends MovieClip 
	{
		private var dealHolder:MovieClip;
		private var rowCount:uint = 0;
		private var tf_bigRed:TextFormat;
		private var tf_smallRed:TextFormat;
		private var tf_black:TextFormat;
		private var tf_blackBold:TextFormat;
		private var tf_supRed:TextFormat;
		private var tf_supBlack:TextFormat;
		private var dealsShownCount:uint = 0;
		public var _preloader:MovieClip
		
		private var deals:Array = [];
		
		
		
		//_____________config vars ________________________________
		
		private var dealRowSpacing:Number = 35;
		private var tf_rollOverHelv:TextFormat;
		private var model:LandingclipModel;
		private var tf_disclaimerText:TextFormat;


		
		public function LandingclipView() 
		{
			var interstateCond:Font = new InterstateCondensed();
			var interstateBoldCond:Font = new InterstateCondensedBold();
			var helveticaNeueCond:Font = new HelveticaNeueCond();
			
			tf_bigRed = new TextFormat(interstateCond.fontName, 36, 0xcc202c);
			
			tf_smallRed = new TextFormat(interstateCond.fontName, 21, 0xcc202c);
			tf_black = new TextFormat(interstateCond.fontName, 21, 0x000000);
			tf_blackBold = new TextFormat(interstateBoldCond.fontName, 21, 0x000000);
			tf_supRed = new TextFormat(interstateCond.fontName, 20, 0xcc202c);
			tf_supBlack = new TextFormat(interstateCond.fontName, 16, 0x000000);
			tf_rollOverHelv = new TextFormat(helveticaNeueCond.fontName, 10, 0x000000);
			tf_disclaimerText = new TextFormat(interstateCond.fontName, 14, 0x000000);
			tf_disclaimerText.leading = -2;
			tf_bigRed.letterSpacing = tf_smallRed.letterSpacing = tf_black.letterSpacing = tf_blackBold.letterSpacing = tf_supBlack.letterSpacing = tf_supRed.letterSpacing = -.5;
		
			
			
			
			model = new LandingclipModel(this);
			model.addEventListener(CustomEvent.INCENTIVES_LOADED, onIncentivesLoaded);
			model.addEventListener(CustomEvent.INCENTIVES_LOADING, onIncentivesLoading);
			
		}
		
		public function loadIncentives(zip:String) {
			_preloader = this.parent["preloader_mc"];
			TweenLite.to(_preloader, .5, { alpha:1 } );
			model.loadIncentives(zip, "") ;
		}
		
		private function onIncentivesLoaded(e:CustomEvent):void {
			var incentives:Array = e.data;
			TweenLite.to(_preloader, .5, { alpha: 0, onComplete:function(e) { _preloader.visible = false } } );
			createDeals(incentives);
		}
		
		private function createDeals(incentives:Array) {
			if (incentives.length > 0){
				dealHolder = new MovieClip();
				
				dealHolder.x = 375;
				dealHolder.y = 36;
				addChild(dealHolder);
				for (var i:int = 0; i < incentives.length ; i++){				
					var d:Sprite = createDeal(incentives[i]);
					d.alpha = 0;
					deals.push(d);
					rowCount ++
				}
				
				var showTimer:Timer = new Timer(400, 3);
				showTimer.addEventListener(TimerEvent.TIMER, showNextDeal);
				showTimer.start();
			} else {
				var failClip:Sprite = new FailClip();
				addChild(failClip);
				failClip.x = 430;
				trace('No incentives');
			}
		}
		
		private function showNextDeal(e:TimerEvent):void {
			TweenLite.to(deals[dealsShownCount], 1, { alpha:1 } );
			dealsShownCount ++;
		}
		
		private function createDeal(dealObj:IncentivesDO):Sprite {	
			var dealClip:Sprite = new Sprite();

			dealHolder.addChild(dealClip);

			var image:DisplayObject = dealClip.addChild(dealObj.carImage) as DisplayObject;
			var dealtxt:Sprite = dealClip.addChild(buildTextClip(dealObj)) as Sprite;
			dealtxt.name = "dealTxt_mc";
			
			dealtxt.x = image.width + 5;
			if (dealtxt.width >= 450) {
				var ratio:Number = 450 / dealtxt.width;
				dealtxt.scaleX = dealtxt.scaleY = ratio;
			}
			
			dealClip.y = rowCount * (image.height + dealRowSpacing);
			var disclaimerTxt:Sprite = dealClip.addChild(createDisclaimer(dealObj, 450, dealClip.height,dealClip.y+(dealClip.height/2))) as Sprite;
			disclaimerTxt.buttonMode = false;
			disclaimerTxt.mouseEnabled = false;
			disclaimerTxt.name = "disclaimerTxt_mc";
			disclaimerTxt.y -= dealClip.y;
			disclaimerTxt.x = dealtxt.x;
			
			var rollOverText:TextField = new TextField();
			rollOverText.embedFonts = true;
			rollOverText.autoSize = TextFieldAutoSize.LEFT;
			rollOverText.selectable = false;
			rollOverText.text = "ROLL OVER FOR DISCLAIMER";
			rollOverText.setTextFormat(tf_rollOverHelv);
			dealtxt.addChild(rollOverText);
			rollOverText.y = 42;
			rollOverText.x = 0
			
			var dealClipHit:Sprite = new Sprite();
			dealClipHit.graphics.beginFill(0x000000, 0);
			dealClipHit.graphics.drawRect(rollOverText.x-10+dealtxt.x,rollOverText.y-10, rollOverText.textWidth+20, rollOverText.textHeight+20);
			//dealClipHit.buttonMode = true;
			dealClip.addChild(dealClipHit);
			dealClipHit.addEventListener(MouseEvent.MOUSE_OVER, dealOver);
			dealClipHit.addEventListener(MouseEvent.MOUSE_OUT, dealout);
			dealClipHit.addEventListener(MouseEvent.CLICK, dealClick);
			
			
			
			return dealClip;
		}
		private function createDisclaimer(dealObj:IncentivesDO,w:Number, h:Number,arrowPoint:Number):Sprite {
			var disclaimerHolder:Sprite = new Sprite();
			disclaimerHolder.alpha = 0;
			disclaimerHolder.visible = false;
			disclaimerHolder.mouseEnabled = false;
			disclaimerHolder.buttonMode = false;
		
			var disclaimerTextField:TextField = new TextField();
			disclaimerTextField.embedFonts = true;
			disclaimerTextField.multiline = true;
			disclaimerTextField.wordWrap = true;
			disclaimerTextField.width = w - 40;
			disclaimerTextField.text = dealObj.disclaimer;
			disclaimerTextField.setTextFormat(tf_disclaimerText);
			disclaimerTextField.x = 30;
			disclaimerTextField.y = 10;
			disclaimerTextField.selectable = false;
			disclaimerTextField.autoSize = TextFieldAutoSize.LEFT
			disclaimerTextField.mouseEnabled = false;
			disclaimerHolder.graphics.beginFill(0x000000, .1);
			disclaimerHolder.graphics.drawRoundRect(20, 0, w - 20, disclaimerTextField.textHeight + 20, 10); 
			disclaimerHolder.graphics.moveTo(20, (disclaimerTextField.height/2)-(arrowPoint/6));
			disclaimerHolder.graphics.lineTo(0, arrowPoint);
			disclaimerHolder.graphics.lineTo(20, (disclaimerTextField.height/2)+(arrowPoint/6));
			disclaimerHolder.buttonMode = false;
			
			disclaimerHolder.addChild(disclaimerTextField);
			return disclaimerHolder;
		}

		

		
		
		private function buildCarImage(carImage:DisplayObject):Sprite {
			var dealImgHolder:Sprite = new Sprite();
			
			dealImgHolder.addChild(carImage);
			trace(carImage);
			carImage.y = -10;
			
			return dealImgHolder;
		}

		private function buildTextClip(dealObj:IncentivesDO):Sprite {
			var textContainer:Sprite = new Sprite();
			var dealChunks:Array = [];
			var dealText:TextField = new TextField();
			dealText.embedFonts = true;
			dealText.autoSize = TextFieldAutoSize.LEFT;
			dealText.selectable = false;
			
			
			switch(dealObj.includesLease) {	
				case "NO":
					dealChunks = buildBuyString(dealObj);
					break;
					
				case null:
					dealChunks = buildLeaseString(dealObj);
					break;
			}
			
			for (var i:int = 0; i < dealChunks.length; i++) {
				var startPos:uint = dealText.length;
				var txt:String = dealChunks[i].txt;
				var style:TextFormat = dealChunks[i].style;
			
				if(style != tf_supRed && style != tf_supBlack){
					dealText.appendText(txt.toUpperCase());
					dealText.setTextFormat(style, startPos, dealText.length); 
				} else {
					var supText:TextField = new TextField();
					supText.embedFonts = true;
					supText.text = txt;
					supText.autoSize = TextFieldAutoSize.LEFT;
					supText.selectable = false;
					textContainer.addChild(supText);
					
					if(style ==  tf_supRed){
						supText.x = dealText.textWidth - 4 ;
						supText.y = 4;
						dealText.appendText(" ");
						supText.setTextFormat(tf_supRed);
					} else if (style ==  tf_supBlack) {
						supText.x = dealText.textWidth - 4 ;
						supText.y = 6;
						dealText.appendText(" ");
						supText.setTextFormat(tf_supBlack);
					}
				}
			}	
			
			//textContainer.width = dealText.textWidth
			textContainer.addChild(dealText);
			return textContainer;
		}
		
		private function createSuper(txt:String):TextField {
			var tf:TextField = new TextField();
			tf.embedFonts = true;
			tf.setTextFormat(tf_supRed);
			tf.text = txt;
			return tf;
		}
		
		private function buildLeaseString(dealObj:IncentivesDO):Array {			
			var leaseChunks:Array =new Array(
				{ txt:"$" + removeCents(dealObj.leaseMonthlyPayment), style:tf_bigRed },
				{ txt:" a month lease for ", style:tf_black },
				{ txt:dealObj.leaseTerm + " months with ", style:tf_blackBold},
				{ txt:"$" + removeCents(dealObj.leaseDueAtSigning) + " due at signing on ", style:tf_black },
				{ txt:dealObj.applicableModel.slice(1) + " " + dealObj.seriesName, style:tf_smallRed}
			);
			
			return  leaseChunks;
		}
		
		//build all textfields for each section and push them into an array to be laid out by the compileTextClip function
		private function buildBuyString(dealObj:IncentivesDO):Array {
			var buyChunks:Array = []
			if (dealObj.aprData.length > 0) { 
				buyChunks.push( { txt:roundPercentage(dealObj.aprData[0].rate)+ " " , style:tf_bigRed} );
				buyChunks.push( { txt:"%", style: tf_supRed } );
				buyChunks.push( { txt:" for ", style:tf_black } );
				buyChunks.push( { txt:dealObj.aprData[0].term + " months", style:tf_blackBold } );
				if (dealObj.cashBack) buyChunks.push( { txt:" or  ", style:tf_black } );
			}
			
			if (dealObj.cashBack) {
				buyChunks.push( { txt:"$", style:tf_supRed } );
				buyChunks.push( { txt:removeCents(dealObj.cashBack), style:tf_bigRed } );
				buyChunks.push( { txt:" cash back", style:tf_blackBold } );	
			}
			buyChunks.push( { txt:" on ", style:tf_black } );
			buyChunks.push( { txt:dealObj.applicableModel.slice(1) + " " + dealObj.seriesName, style:tf_smallRed } );
			return buyChunks;
		}
		
		
		
		private function dealClick(e:MouseEvent):void {
			
		}
		
		private function dealout(e:MouseEvent):void {
			var tf:Sprite = e.currentTarget.parent.getChildByName('disclaimerTxt_mc');
			TweenLite.to(tf, .2, { alpha:0, onComplete:function(e){ tf.visible = false } } );
			
			for (var i:int = 0; i < e.currentTarget.parent.numChildren; i++) {
				try { TweenLite.to(deals[i].getChildByName('dealTxt_mc'), .2, { alpha:1, onComplete:function() { tf.visible = false} } ) } catch (e:Error) { }
			}
		}
		
		private function dealOver(e:MouseEvent):void {
			e.currentTarget.parent.getChildByName('disclaimerTxt_mc').visible = true;
			TweenLite.to(e.currentTarget.parent.getChildByName('disclaimerTxt_mc'), .2, { alpha:1 } );
			for (var i:int = 0; i < e.currentTarget.parent.numChildren; i++) {
				try {TweenLite.to(deals[i].getChildByName('dealTxt_mc'), .2, { alpha:0 }); } catch (e:Error) {}
			}
		}
		

		//______________________ utils __________________________________________________________
		
		private function roundPercentage(num:String):String {
			return num.slice(0, num.indexOf(".") + 2);
		}
		
		private function removeCents(price:String):String {
			var hasDec:Number = price.indexOf(".");
			if(price.search(".") >= 0){
				var newPrice:String
				if (hasDec >= 0) {
					newPrice = price.slice(0, hasDec);
					return newPrice;
				} 
			}
			return price;
		}	
		
		private function onIncentivesLoading(e:CustomEvent):void {
			var loadingObj:Object = e.data;
			(loadingObj.bytesLoaded, loadingObj.bytesTotal);
			if (loadingObj.bytesLoaded < loadingObj.bytesTotal) {
				
				_preloader.percentTxt.text = Math.round((loadingObj.bytesLoaded / loadingObj.bytesTotal) * 100);
			}
			//trace("loading ",loadingObj.bytesLoaded," of ", loadingObj.bytesTotal);
		}
	}
}