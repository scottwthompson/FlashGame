package 
{
		import fl.controls.TextArea;
		import flash.display.MovieClip;
		import flash.events.Event;
		import flash.events.MouseEvent;
		import flash.text.TextField;
		import flash.text.TextFormat;
	/**
	 * ...
	 * @author Scott Thompson
	 */
	public class mcFeedbackScreen  extends MovieClip 
	{
		public var failureEmailText:MovieClip;
		public var failureScreen:MovieClip;
		public var successEmailText:MovieClip;
		public var successScreen:MovieClip;
		
		public var mcLevelSelectBtn:MovieClip;
		public var mcRestartBtn:MovieClip;
		public var mcContinueBtn:MovieClip;
		public var mcNextLevelBtn:MovieClip;
		
		public var mcSettingsBtn:MovieClip;
		
		public var myFormat:TextFormat;
		
		public var mcFeedbackText:TextArea;
		
		public function mcFeedbackScreen() 
		{
			failureEmailText.visible = false;
			successEmailText.visible = false;
			successScreen.visible = false;
			failureScreen.visible = false;
			
			mcLevelSelectBtn.buttonMode = true;
			mcLevelSelectBtn.addEventListener(MouseEvent.CLICK, selectLevel);
			
			mcRestartBtn.buttonMode = true;
			mcRestartBtn.addEventListener(MouseEvent.CLICK, restartLevel);
			
			mcContinueBtn.buttonMode = true;
			mcContinueBtn.addEventListener(MouseEvent.CLICK, continueLevel);
			
			mcNextLevelBtn.buttonMode = true;
			mcNextLevelBtn.addEventListener(MouseEvent.CLICK, nextLevel);
				
			
			//this.visible = false;
			mcSettingsBtn.buttonMode = true;
			mcSettingsBtn.addEventListener(MouseEvent.CLICK, openSettings);
			
			mcFeedbackText.editable = false;
		}
		
		private function openSettings(e:MouseEvent):void 
		{
			var ev = new Event("OPEN_SETTINGS");
			dispatchEvent(ev);
		}
		
		private function continueLevel(e:MouseEvent):void 
		{
			this.visible = false;
		}
		
		private function nextLevel(e:Event):void 
		{
			var ev = new Event("NEXT_LEVEL");
			dispatchEvent(ev);
		}
		
		private function restartLevel(e:Event):void 
		{
			var ev = new Event("RESTART_LEVEL");
			dispatchEvent(ev);
		}
		
		private function selectLevel(e:Event):void 
		{
			var ev = new Event("SELECT_LEVEL");
			dispatchEvent(ev);
		}
		
		public function showsScreen(bool:Boolean):void {
			if (!bool) {
				failureEmailText.visible = false;
				failureScreen.visible = false;
				successEmailText.visible = true;
				successScreen.visible = true;
				this.visible = true;
			} else {
				successEmailText.visible = false;
				successScreen.visible = false;
				failureEmailText.visible = true;
				failureScreen.visible = true;
				this.visible = true;
			}
		}
		
		public function hideScreen():void {
			this.visible = false;
			failureEmailText.visible = false;
			successEmailText.visible = false;
		}
		public function update(feedback:String) {
			mcFeedbackText.text = feedback;
		}
	}

}