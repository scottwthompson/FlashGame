package 
{
		import flash.display.MovieClip;
		import flash.events.Event;
		import flash.events.MouseEvent;
	/**
	 * ...
	 * @author Scott Thompson
	 */
	public class mcLevelSelectScreen  extends MovieClip 
	{
		
		public var mcSettingsBtn:MovieClip;
		
		public var levelBtn1:MovieClip;
		public var levelBtn2:MovieClip;
		public var levelBtn3:MovieClip;
		public var levelBtn4:MovieClip;
		public var levelBtn5:MovieClip;
		public var levelBtn6:MovieClip;
		public var levelBtn7:MovieClip;
		public var levelBtn8:MovieClip;
		public var levelBtn9:MovieClip;
		public var levelBtn10:MovieClip;
		public var levelBtn11:MovieClip;
		public var levelBtn12:MovieClip;
		public var levelBtn13:MovieClip;
		public var levelBtn14:MovieClip;
		public var levelBtn15:MovieClip;
		public var levelBtn16:MovieClip;
		public var levelBtn17:MovieClip;
		public var levelBtn18:MovieClip;
		public var levelBtn19:MovieClip;
		public var levelBtn20:MovieClip;
		public var levelBtn21:MovieClip;
		public var levelBtn22:MovieClip;
		public var levelBtn23:MovieClip;
		public var levelBtn24:MovieClip;
		public var levelBtn25:MovieClip;
		public var levelButtons: Array;
		
		public var mcHomeBtn:MovieClip;
		
		public var currLevel:int = 0;
		
		
		public function mcLevelSelectScreen() 
		{
			super();
			levelButtons = new Array(levelBtn1, levelBtn2, levelBtn3, levelBtn4, levelBtn5,levelBtn6,levelBtn7,levelBtn8,levelBtn9,levelBtn10,levelBtn11,levelBtn12,levelBtn13,levelBtn14,levelBtn15,levelBtn16,levelBtn17,levelBtn18,levelBtn19,levelBtn20);
			for (var x:String in levelButtons) {
				levelButtons[x].buttonMode = true;
				levelButtons[x].addEventListener(MouseEvent.CLICK, selectLevel);
			}
			
			mcHomeBtn.buttonMode = true;
			mcHomeBtn.addEventListener(MouseEvent.CLICK, backHome);
			
			mcSettingsBtn.buttonMode = true;
			mcSettingsBtn.addEventListener(MouseEvent.CLICK, openSettings);
		}
		
		private function backHome(e:MouseEvent):void 
		{
			trace("hey");
			var ev = new Event("BACK_HOME");
			dispatchEvent(ev);
		}
		
		private function openSettings(e:MouseEvent):void 
		{
			var ev = new Event("OPEN_SETTINGS");
			dispatchEvent(ev);
		}
		
		private function selectLevel(e:Event):void 
		{
			currLevel = levelButtons.indexOf(e.currentTarget as MovieClip);
			var ev = new Event("START_LEVEL");
			dispatchEvent(ev);
		}	
		
		public function showsScreen():void {
			this.visible = true;
		}
		
		public function hideScreen():void {
			this.visible = false;
		}
		
		public function isvisible():Boolean {
			return this.visible;
		}
		
	}

}