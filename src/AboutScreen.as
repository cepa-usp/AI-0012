package  
{
	import flash.display.MovieClip;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;
	/**
	 * ...
	 * @author Alexandre
	 */
	public class AboutScreen extends MovieClip
	{
		
		public function AboutScreen() 
		{
			this.x = 650 / 2;
			this.y = 500 / 2;
			
			this.gotoAndStop("END");
			
			this.addEventListener(MouseEvent.CLICK, closeScreen);
			stage.addEventListener(KeyboardEvent.KEY_UP, escCloseScreen);
		}
		
		private function escCloseScreen(e:KeyboardEvent):void 
		{
			if (e.keyCode ==  Keyboard.ESCAPE) {
				if(this.currentFrame == 1) this.play();
			}
		}
		
		private function closeScreen(e:MouseEvent):void 
		{
			this.play();
		}
		
		public function openScreen():void
		{
			this.gotoAndStop("BEGIN");
		}
		
	}

}