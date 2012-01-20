package 
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	/**
	 * ...
	 * @author Alexandre
	 */
	public class CaixaTexto extends Sprite
	{
		private var texto:TextField;
		private var background:Sprite;
		private var closeButton:CloseButton;
		
		private var marginText:Number = 15;
		
		public function CaixaTexto() 
		{
			background = new Sprite();
			addChild(background);
			
			texto = new TextField();
			texto.defaultTextFormat = new TextFormat("arial", 12, 0x000000);
			texto.multiline = true;
			texto.wordWrap = true;
			texto.autoSize = TextFieldAutoSize.LEFT;
			texto.selectable = false;
			texto.x = marginText;
			texto.y = marginText;
			addChild(texto);
			
			closeButton = new CloseButton();
			addChild(closeButton);
			closeButton.addEventListener(MouseEvent.CLICK, closeThis);
		}
		
		private function closeThis(e:MouseEvent):void 
		{
			this.visible = false;
		}
		
		private function drawBackground(w:Number, h:Number):void
		{
			background.graphics.clear();
			background.graphics.lineStyle(1, 0x000000);
			background.graphics.beginFill(0x00FFFF);
			background.graphics.drawRoundRect(0, 0, w, h, 10, 10);
			background.graphics.endFill();
			
			background.graphics.lineStyle(1, 0x00FFFF);
			background.graphics.beginFill(0x00FFFF);
			background.graphics.moveTo(0, 5);
			background.graphics.lineTo(-15, 10);
			background.graphics.lineTo(0, 15);
			background.graphics.lineTo(0, 5);
			background.graphics.endFill();
			
			background.graphics.lineStyle(1, 0x000000);
			background.graphics.moveTo(0, 5);
			background.graphics.lineTo(-15, 10);
			background.graphics.lineTo(0, 15);
		}
		
		public function setText(text:String, width:Number = 200):void
		{
			texto.width = width;
			texto.text = text;
			drawBackground(texto.textWidth + 2 * marginText, texto.textHeight + 2 * marginText);
			closeButton.x = background.width - 4 - 15;
			closeButton.y = 3;
			this.visible = true;
		}
		
		public function setPosition(x:Number, y:Number):void
		{
			this.x = x;
			this.y = y;
		}
		
	}

}