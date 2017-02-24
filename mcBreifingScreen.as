package 
{
		import fl.controls.TextArea;
		import flash.display.MovieClip;
		import flash.events.Event;
		import flash.events.MouseEvent;
		import flash.text.Font;
		import flash.text.TextField;
		import flash.text.TextFormat;

	/**
	 * ...
	 * @author Scott Thompson
	 */
	public class mcBreifingScreen  extends MovieClip 
	{
		public var mcLevelSelectBtn:MovieClip;
		public var mcContinueBtn:MovieClip;
		public var mcBreifText:TextArea;
		
		public var myFormat:TextFormat;
		
		public var mcSettingsBtn:MovieClip;
		
		public function mcBreifingScreen() 
		{
			mcLevelSelectBtn.buttonMode = true;
			mcLevelSelectBtn.addEventListener(MouseEvent.CLICK, selectLevel);
			
			mcContinueBtn.buttonMode = true;
			mcContinueBtn.addEventListener(MouseEvent.CLICK, continueGame);
			
			mcSettingsBtn.buttonMode = true;
			mcSettingsBtn.addEventListener(MouseEvent.CLICK, openSettings);
			
			mcBreifText.editable = false;
			
			myFormat = new TextFormat();
			myFormat.size = 20;
			myFormat.color = 0x000000;
		}
		
		private function openSettings(e:MouseEvent):void 
		{
			var ev = new Event("OPEN_SETTINGS");
			dispatchEvent(ev);
		}
		
		private function continueGame(e:Event):void 
		{
			this.visible = false;
		}
		
		private function selectLevel(e:Event):void 
		{
			var ev = new Event("SELECT_LEVEL");
			dispatchEvent(ev);
		}
		
		public function showsScreen():void {
			this.visible = true;
		}
		
		public function hideScreen():void {
			this.visible = false;
		}
		
		public function update(brief:String) {
			mcBreifText.text = brief;
		}
		
		public function isvisible():Boolean {
			return this.visible;
		}
	}

}