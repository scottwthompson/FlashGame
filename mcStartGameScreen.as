package 
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	/**
	 * ...
	 * @author Scott Thompson
	 */
	public class mcStartGameScreen extends MovieClip 
	{
		public var mcStartBtn:MovieClip;
		public var mcSettingsBtn:MovieClip;
		
		public function mcStartGameScreen() {
			super();
			mcStartBtn.buttonMode = true;
			mcStartBtn.addEventListener(MouseEvent.CLICK, startClick);
			mcSettingsBtn.buttonMode = true;
			mcSettingsBtn.addEventListener(MouseEvent.CLICK, startSettings);
	
		}
		
		private function startSettings(e:MouseEvent):void 
		{
			dispatchEvent(new Event("START_GAME"));
		}
		
		private function startClick(e:MouseEvent):void {
			dispatchEvent(new Event("START_GAME"));
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