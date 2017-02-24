package 
{
		import flash.display.MovieClip;
		import flash.events.Event;
		import flash.events.MouseEvent;
	/**
	 * ...
	 * @author Scott Thompson
	 */
	public class mcSettingsScreen  extends MovieClip 
	{
		
		public var mcEasyBtn:MovieClip;
		public var mcMediumBtn:MovieClip;
		public var mcHardBtn:MovieClip;
		
		public var difficulty:int = 0;
		
		public function mcSettingsScreen() 
		{
			super();
			mcEasyBtn.buttonMode = true;
			mcEasyBtn.addEventListener(MouseEvent.CLICK, setEasy);
			
			mcMediumBtn.buttonMode = true;
			mcMediumBtn.addEventListener(MouseEvent.CLICK, setMedium);
			
			mcHardBtn.buttonMode = true;
			mcHardBtn.addEventListener(MouseEvent.CLICK, setHard);
		}
		
		private function setHard(e:Event):void 
		{
			difficulty = 2;
			hideScreen();
			var ev = new Event("DIFF_UPDATE");
			dispatchEvent(ev);
		}
		
		private function setMedium(e:Event):void 
		{
			difficulty = 1;
			hideScreen();
			var ev = new Event("DIFF_UPDATE");
			dispatchEvent(ev);
		}
		
		private function setEasy(e:Event):void 
		{
			difficulty = 0;
			hideScreen();
			var ev = new Event("DIFF_UPDATE");
			dispatchEvent(ev);
		}
		
		public function showsScreen():void {
			this.visible = true;
		}
		
		public function hideScreen():void {
			this.visible = false;
		}
		
	}

}