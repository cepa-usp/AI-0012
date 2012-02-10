package  
{
	import cepa.utils.ToolTip;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.display.StageDisplayState;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.ui.Keyboard;
	import flash.utils.Timer;
	import org.papervision3d.core.geom.Lines3D;
	import org.papervision3d.core.geom.renderables.Line3D;
	import org.papervision3d.core.geom.renderables.Vertex3D;
	import org.papervision3d.core.math.Number3D;
	import org.papervision3d.core.proto.MaterialObject3D;
	import org.papervision3d.events.FileLoadEvent;
	import org.papervision3d.materials.ColorMaterial;
	import org.papervision3d.materials.shadematerials.CellMaterial;
	import org.papervision3d.materials.shadematerials.FlatShadeMaterial;
	import org.papervision3d.materials.shadematerials.GouraudMaterial;
	import org.papervision3d.materials.shadematerials.PhongMaterial;
	import org.papervision3d.materials.special.Letter3DMaterial;
	import org.papervision3d.materials.special.LineMaterial;
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.objects.parsers.DAE;
	import org.papervision3d.objects.primitives.Cylinder;
	import org.papervision3d.objects.primitives.PaperPlane;
	import org.papervision3d.objects.primitives.Plane;
	import org.papervision3d.objects.primitives.Sphere;
	import org.papervision3d.typography.Font3D;
	import org.papervision3d.typography.fonts.HelveticaBold;
	import org.papervision3d.typography.Text3D;
	import org.papervision3d.view.BasicView;
	import org.papervision3d.view.layer.ViewportLayer;
	/**
	 * ...
	 * @author Alexandre
	 */
	public class Main extends BasicView
	{
		/**
		 * Eixos x, y e z.
		 */
		private var eixos:CartesianAxis3D;
		
		/**
		 * Posição do click na tela.
		 */
		private var clickPoint:Point = new Point();
		
		/*
		 * Filtro de conversão para tons de cinza.
		 */
		private const GRAYSCALE_FILTER:ColorMatrixFilter = new ColorMatrixFilter([
			0.2225, 0.7169, 0.0606, 0, 0,
			0.2225, 0.7169, 0.0606, 0, 0,
			0.2225, 0.7169, 0.0606, 0, 0,
			0.0000, 0.0000, 0.0000, 1, 0
		]);
		
		private var cilindro:Cylinder;
		private var planeTeta:DisplayObject3D;
		private var planeZ:Plane;
		private var lines:Lines3D;
		private var planeTetaInside:Plane;
		private var linesInter:Lines3D;
		private var interPlaneLines:Lines3D;
		private var intersecao:Sphere;
		private var interLetter:Text3D;
		private var containerP:DisplayObject3D;
		
		public var distance:Number = 100; 
		private var upVector:Number3D = new Number3D(0, 0, 1);
		
		private var raio:TextField;
		private var teta:TextField;
		private var ze:TextField;
		
		private var balao:CaixaTexto;
		private var tutoSequence:Array = ["Especifique as coordenadas do ponto P nestas caixas de texto (pressione enter para confirmar ou esc para cancelar).", 
										  "Quando as três coordenadas são dadas, obtemos o ponto P definido pela interseção das superfícies associadas a cada coordenada.",
										  "Clique e arraste o mouse sobre a ilustração para modificar o ângulo de visão.",
										  "Use os botões de zoom para ampliar ou reduzir."];
		
		private var pointsTuto:Array;
		private var tutoBaloonPos:Array;
		private var tutoPos:int;
		private var tutoPhase:Boolean;
		private var pontoP:Point = new Point();
		
		public function Main() 
		{	
			super(650, 500, false, false);
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
			
			startRendering();
		}
		
		private function init(e:Event = null):void
		{
			this.scrollRect = new Rectangle(0, 0, 650, 500);
			stage.scaleMode = StageScaleMode.SHOW_ALL;
			
			eixos = new CartesianAxis3D();
			
			scene.addChild(eixos);
			
			camera.target = null;
			
			raio = coordenadas.raio;
			teta = coordenadas.teta;
			ze = coordenadas.ze;
			
			rotating(null);
			
			botoes.info.addEventListener(MouseEvent.CLICK, showInfo);
			botoes.instructions.addEventListener(MouseEvent.CLICK, showCC);
			botoes.btnInst.addEventListener(MouseEvent.CLICK, openInst);
			botoes.resetButton.addEventListener(MouseEvent.CLICK, resetCamera);
			
			stage.addEventListener(MouseEvent.MOUSE_DOWN, initRotation);
			stage.addEventListener(KeyboardEvent.KEY_UP, keyUp);
			
			stage.addEventListener(MouseEvent.MOUSE_WHEEL, viewZoom);
			//zoomBtns.zoomIn.addEventListener(MouseEvent.CLICK, viewZoom);
			//zoomBtns.zoomOut.addEventListener(MouseEvent.CLICK, viewZoom);
			zoomBtns.zoomIn.addEventListener(MouseEvent.MOUSE_DOWN, initZoom);
			zoomBtns.zoomOut.addEventListener(MouseEvent.MOUSE_DOWN, initZoom);
			zoomBtns.zoomIn.mouseChildren = false;
			zoomBtns.zoomOut.mouseChildren = false;
			zoomBtns.zoomIn.buttonMode = true;
			zoomBtns.zoomOut.buttonMode = true;
			zoomBtns.zoomIn.addEventListener(MouseEvent.MOUSE_OVER, over);
			zoomBtns.zoomOut.addEventListener(MouseEvent.MOUSE_OVER, over);
			
			var infoTT:ToolTip = new ToolTip(botoes.info, "Informações", 12, 0.8, 100, 0.6, 0.1);
			var instTT:ToolTip = new ToolTip(botoes.instructions, "Orientações", 12, 0.8, 150, 0.6, 0.1);
			var resetTT:ToolTip = new ToolTip(botoes.resetButton, "Reiniciar", 12, 0.8, 100, 0.6, 0.1);
			var intTT:ToolTip = new ToolTip(botoes.btnInst, "Reiniciar tutorial", 12, 0.8, 150, 0.6, 0.1);
			
			addChild(infoTT);
			addChild(instTT);
			addChild(resetTT);
			addChild(intTT);
			
			setChildIndex(coordenadas, numChildren - 1);
			setChildIndex(zoomBtns, numChildren - 1);
			setChildIndex(botoes, numChildren - 1);
			setChildIndex(borda, numChildren - 1);
			
			adicionaListenerCampos();
			
			initCampos();
			
			lookAtP();
			
			iniciaTutorial();
			verifyZoomBtns();
		}
		
		private var timerToZoom:Timer = new Timer(200);
		private function initZoom(e:MouseEvent):void 
		{
			if (e.target.name == "zoomIn") {
				if (zoom < 120) zoom +=  5;
				timerToZoom.addEventListener(TimerEvent.TIMER, zooningIn);
			}else {
				if (zoom > 40) zoom -=  5;
				timerToZoom.addEventListener(TimerEvent.TIMER, zooningOut);
			}
			timerToZoom.start();
			stage.addEventListener(MouseEvent.MOUSE_UP, stopZooning);
			
			verifyZoomBtns();
			
			this.camera.zoom = zoom;
		}
		
		private function zooningIn(e:TimerEvent):void 
		{
			if (zoom < 120) {
				zoom +=  5;
				this.camera.zoom = zoom;
			}
			verifyZoomBtns();
		}
		
		private function zooningOut(e:TimerEvent):void 
		{
			if (zoom > 40) {
				zoom -=  5;
				this.camera.zoom = zoom;
			}
			verifyZoomBtns();
		}
		
		private function stopZooning(e:MouseEvent):void 
		{
			timerToZoom.stop();
			timerToZoom.reset();
			timerToZoom.removeEventListener(TimerEvent.TIMER, zooningIn);
			timerToZoom.removeEventListener(TimerEvent.TIMER, zooningOut);
		}
		
		private function verifyZoomBtns():void
		{
			if (zoom == 40) {
				zoomBtns.zoomOut.mouseEnabled = false;
				zoomBtns.zoomOut.filters = [GRAYSCALE_FILTER];
				zoomBtns.zoomOut.alpha = 0.3;
			}
			else {
				zoomBtns.zoomOut.mouseEnabled = true;
				zoomBtns.zoomOut.filters = [];
				zoomBtns.zoomOut.alpha = 1;
			}
			
			if (zoom == 120) {
				zoomBtns.zoomIn.mouseEnabled = false;
				zoomBtns.zoomIn.filters = [GRAYSCALE_FILTER];
				zoomBtns.zoomIn.alpha = 0.3;
			}
			else {
				zoomBtns.zoomIn.mouseEnabled = true;
				zoomBtns.zoomIn.filters = [];
				zoomBtns.zoomIn.alpha = 1;
			}
		}
		
		private function keyUp(e:KeyboardEvent):void 
		{
			if(e.charCode == Keyboard.ESCAPE){
				if (stage.focus == raio) {
					if (cilindro != null) raio.text = String(raioNumber);
					else raio.text = "";
					stage.focus = null;
				}else if (stage.focus == teta) {
					if (planeTeta != null) teta.text = String(anguloTeta);
					else teta.text = "";
					stage.focus = null;
				}else if (stage.focus == ze) {
					if (planeZ != null) ze.text = String(Math.abs(planeZ.z));
					else ze.text = "";
					stage.focus = null;
				}
			}
		}
		
		private function over(e:MouseEvent):void 
		{
			var btn:MovieClip = MovieClip(e.target);
			btn.addEventListener(MouseEvent.MOUSE_OUT, out);
			btn.gotoAndStop(2);
		}
		
		private function out(e:MouseEvent):void 
		{
			var btn:MovieClip = MovieClip(e.target);
			btn.removeEventListener(MouseEvent.MOUSE_OUT, out);
			btn.gotoAndStop(1);
		}
		
		private function iniciaTutorial():void 
		{
			tutoPos = 0;
			tutoPhase = true;
			getPCoord();
			
			if(balao == null){
				balao = new CaixaTexto(true);
				addChild(balao);
				balao.visible = false;
				
				pointsTuto = 	[new Point(coordenadas.x + coordenadas.width, coordenadas.y + coordenadas.height/2),
								pontoP,
								new Point(650/2, 500/2),
								new Point(zoomBtns.x + zoomBtns.width, zoomBtns.y + zoomBtns.height / 2)];
								
				tutoBaloonPos = [[CaixaTexto.LEFT, CaixaTexto.FIRST],
								[CaixaTexto.LEFT, CaixaTexto.FIRST],
								[CaixaTexto.TOP, CaixaTexto.CENTER],
								[CaixaTexto.LEFT, CaixaTexto.FIRST]];
			}
			balao.removeEventListener(Event.CLOSE, closeBalao);
			
			balao.setText(tutoSequence[tutoPos], tutoBaloonPos[tutoPos][0], tutoBaloonPos[tutoPos][1]);
			balao.setPosition(pointsTuto[tutoPos].x, pointsTuto[tutoPos].y);
			balao.addEventListener(Event.CLOSE, closeBalao);
			balao.visible = true;
		}
		
		private function getPCoord():void
		{
			if(intersecao != null){
				var bounds:Rectangle = viewport.getChildLayer(intersecao).getBounds(stage);
				pontoP.x = bounds.x;
				pontoP.y = bounds.y + bounds.height / 2;
				//trace(bounds);
			}
		}
		
		private function closeBalao(e:Event):void 
		{
			//trace("entrou");
			tutoPos++;
			//trace(tutoPos);
			if (tutoPos >= tutoSequence.length) {
				balao.removeEventListener(Event.CLOSE, closeBalao);
				balao.visible = false;
				tutoPhase = false;
			}else {
				if(tutoPos != 1){
					balao.setText(tutoSequence[tutoPos], tutoBaloonPos[tutoPos][0], tutoBaloonPos[tutoPos][1]);
					balao.setPosition(pointsTuto[tutoPos].x, pointsTuto[tutoPos].y);
				}else {
					if(containerP != null){
						getPCoord();
						if (pontoP.x > 650 / 2) tutoBaloonPos[1][0] = CaixaTexto.RIGHT;
						else tutoBaloonPos[1][0] = CaixaTexto.LEFT;
						
						if (pontoP.y > 500 / 2) tutoBaloonPos[1][1] = CaixaTexto.LAST;
						else tutoBaloonPos[1][1] = CaixaTexto.FIRST;
						
						balao.setText(tutoSequence[tutoPos], tutoBaloonPos[tutoPos][0], tutoBaloonPos[tutoPos][1]);
						balao.setPosition(pointsTuto[tutoPos].x, pointsTuto[tutoPos].y);
					}else {
						closeBalao(null);
					}
				}
			}
		}
		
		private function openInst(e:MouseEvent):void 
		{
			//instScreen.openScreen();
			//setChildIndex(instScreen, numChildren - 1);
			iniciaTutorial();
		}
		
		private function showInfo(e:MouseEvent):void 
		{
			aboutScreen.openScreen();
			setChildIndex(aboutScreen, numChildren - 1);
		}
		
		private function showCC(e:MouseEvent):void 
		{
			infoScreen.openScreen();
			setChildIndex(infoScreen, numChildren - 1);
		}
		
		private var zoom:Number = 40;
		private function viewZoom(e:MouseEvent):void
		{
			if(e.type == MouseEvent.MOUSE_WHEEL){
				if(e.delta > 0)
				{
					if(zoom < 120) zoom +=  5;
				}
				if(e.delta < 0)
				{
					if (zoom > 40) zoom -=  5;
				}
			}else {
				trace(e.target.name);
				if (e.target.name == "zoomIn") {
					if(zoom < 120) zoom +=  5;
				}else {
					if (zoom > 40) zoom -=  5;
				}
			}
			
			verifyZoomBtns();
			
			this.camera.zoom = zoom;
		}
		
		private function initCampos():void
		{
			raio.text = "25";
			teta.text = "60";
			ze.text = "25";
			
			if (planeZ != null)
			{
				scene.removeChild(planeZ);
				planeZ = null;
				lines.removeAllLines();
				lines = null;
			}
			
			if (planeTeta != null)
			{
				scene.removeChild(planeTeta);
				planeTeta = null;
				linesInter.removeAllLines();
				linesInter = null;
			}
			
			if (interPlaneLines != null)
			{
				interPlaneLines.removeAllLines();
				interPlaneLines = null;
			}
			
			if(intersecao != null)
			{
				if(planeTeta != null) planeTeta.removeChild(intersecao);
				
				intersecao = null;
			}
			
			if (interLetter != null) 
			{
				containerP.removeChild(interLetter);
				scene.removeChild(containerP);
				interLetter = null;
				containerP = null;
			}
			
			drawCilinder(Number(raio.text));
			drawPlane(Number(teta.text));
			drawPlaneZ(Number(ze.text));
		}
		
		private function adicionaListenerCampos():void
		{
			raio.addEventListener(KeyboardEvent.KEY_UP, changeHandler);
			teta.addEventListener(KeyboardEvent.KEY_UP, changeHandler);
			ze.addEventListener(KeyboardEvent.KEY_UP, changeHandler);
			
			raio.addEventListener(FocusEvent.FOCUS_OUT, changeHandler);
			teta.addEventListener(FocusEvent.FOCUS_OUT, changeHandler);
			ze.addEventListener(FocusEvent.FOCUS_OUT, changeHandler);
			
			raio.addEventListener(FocusEvent.FOCUS_IN, focusInEvent);
			teta.addEventListener(FocusEvent.FOCUS_IN, focusInEvent);
			ze.addEventListener(FocusEvent.FOCUS_IN, focusInEvent);
		}
		
		private function focusInEvent(e:FocusEvent):void 
		{
			if (e.target == raio) {
				coordenadas.xBkg.gotoAndStop(2);
			}else if (e.target  == teta) {
				coordenadas.yBkg.gotoAndStop(2);
			}else if (e.target  == ze) {
				coordenadas.zBkg.gotoAndStop(2);
			}
		}
		
		private function changeHandler(e:Event):void 
		{
			if (e is KeyboardEvent) {
				if(KeyboardEvent(e).keyCode == Keyboard.ENTER){
					changePlanes(e.target.name);
					stage.focus = null;
					removeFocus();
				}
			}else {
				if (e.target == raio) {
					if (cilindro != null) raio.text = String(raioNumber);
					else raio.text = "";
				}else if (e.target  == teta) {
					if (planeTeta != null) teta.text = String(anguloTeta);
					else teta.text = "";
				}else if (e.target  == ze) {
					if (planeZ != null) ze.text = String(Math.abs(planeZ.z));
					else ze.text = "";
				}
				removeFocus();
			}
		}
		
		private function removeFocus():void 
		{
			coordenadas.xBkg.gotoAndStop(1);
			coordenadas.yBkg.gotoAndStop(1);
			coordenadas.zBkg.gotoAndStop(1);
		}
		
		private function changePlanes(name:String):void 
		{
			switch (name)
			{
				case "raio":
					if (Number(raio.text) > eixos.maxDist) raio.text = String(eixos.maxDist);
					if (Number(raio.text) < 0) raio.text = "0";
					//if (raio.text == "") raio.text = "0";
					drawCilinder(Number(raio.text));
					if (planeZ != null) drawPlaneZ(Number(ze.text));
					if(planeTeta != null) drawPlane(Number(teta.text));
					break;
				case "teta":
					if (Number(teta.text) > 360) teta.text = "360";
					if (Number(teta.text) < 0) teta.text = "0";
					if (teta.text == "")
					{
						if (planeTeta != null)
						{
							scene.removeChild(planeTeta);
							planeTeta = null;
							linesInter.removeAllLines();
							linesInter = null;
						}
						if (interPlaneLines != null)
						{
							interPlaneLines.removeAllLines();
							interPlaneLines = null;
						}
						if(intersecao != null)
						{
							if(planeTeta != null) planeTeta.removeChild(intersecao);
							
							intersecao = null;
						}
						if (interLetter != null) 
						{
							containerP.removeChild(interLetter);
							scene.removeChild(containerP);
							interLetter = null;
							containerP = null;
						}
						anguloTeta = Number.NaN;
					}
					else drawPlane(Number(teta.text));
					break;
				case "ze":
					if (Number(ze.text) > eixos.maxDist) ze.text = String(eixos.maxDist);
					if (Number(ze.text) < 0) ze.text = "0";
					if (ze.text == "")
					{
						if (planeZ != null)
						{
							scene.removeChild(planeZ);
							planeZ = null;
							lines.removeAllLines();
							lines = null;
						}
						if (interPlaneLines != null)
						{
							interPlaneLines.removeAllLines();
							interPlaneLines = null;
						}
						if(intersecao != null)
						{
							if(planeTeta != null) planeTeta.removeChild(intersecao);
							
							intersecao = null;
						}
						if (interLetter != null) 
						{
							containerP.removeChild(interLetter);
							scene.removeChild(containerP);
							interLetter = null;
							containerP = null;
						}
					}
					else drawPlaneZ(Number(ze.text));
					break;
				
				default:
					return;
			}
			verifyNeedOfBallon(name);
		}
		
		private function verifyNeedOfBallon(name:String):void 
		{
			switch(name)
			{
				case "raio":
					if (raio.text == "") {
						if (teta.text == "" && ze.text == "") { //todos nulos
							balao.setText("Com todos os parâmetros nulos não existem planos nem interseções.", CaixaTexto.LEFT, CaixaTexto.FIRST);
						}else if (teta.text == "") {//x e y nulos
							balao.setText("Quando apenas uma coordenada é dadas, temos a superfície associada a esta coordenada.", CaixaTexto.LEFT, CaixaTexto.FIRST);
						}else if (ze.text == "") {//x e z nulos
							balao.setText("Com dois parâmetros nulos existe apenas 1 plano sem interseções.", CaixaTexto.LEFT, CaixaTexto.FIRST);
						}else {//x nulo
							balao.setText("Quando apenas duas coordenadas são dadas, obtemos a curva definida pela interseção das superfícies associadas a cada coordenada.", CaixaTexto.LEFT, CaixaTexto.FIRST);
						}
						balao.setPosition(coordenadas.x + raio.x + raio.width, coordenadas.y + raio.y + raio.height/2);
					}else {
						if(!tutoPhase) balao.visible = false;
					}
					break;
				case "teta":
					if (teta.text == "") {
						if (raio.text == "" && ze.text == "") { //todos nulos
							balao.setText("Com todos os parâmetros nulos não existem planos nem interseções.", CaixaTexto.LEFT, CaixaTexto.FIRST);
						}else if (raio.text == "") {//x e y nulos
							balao.setText("Quando apenas uma coordenada é dadas, temos a superfície associada a esta coordenada.", CaixaTexto.LEFT, CaixaTexto.FIRST);
						}else if (ze.text == "") {//y e z nulos
							balao.setText("Com dois parâmetros nulos existe apenas 1 plano sem interseções.");
						}else {//y nulo
							balao.setText("Quando apenas duas coordenadas são dadas, obtemos a curva definida pela interseção das superfícies associadas a cada coordenada.", CaixaTexto.LEFT, CaixaTexto.FIRST);
						}
						balao.setPosition(coordenadas.x + teta.x + teta.width, coordenadas.y + teta.y + teta.height/2);
					}else {
						if(!tutoPhase) balao.visible = false;
					}
					break;
				case "ze":
					if (ze.text == "") {
						if (teta.text == "" && raio.text == "") { //todos nulos
							balao.setText("Com todos os parâmetros nulos não existem planos nem interseções.", CaixaTexto.LEFT, CaixaTexto.FIRST);
						}else if (teta.text == "") {//z e y nulos
							balao.setText("Quando apenas uma coordenada é dadas, temos a superfície associada a esta coordenada.", CaixaTexto.LEFT, CaixaTexto.FIRST);
						}else if (raio.text == "") {//x e z nulos
							balao.setText("Com dois parâmetros nulos existe apenas 1 plano sem interseções.", CaixaTexto.LEFT, CaixaTexto.FIRST);
						}else {//z nulo
							balao.setText("Quando apenas duas coordenadas são dadas, obtemos a curva definida pela interseção das superfícies associadas a cada coordenada.", CaixaTexto.LEFT, CaixaTexto.FIRST);
						}
						balao.setPosition(coordenadas.x + ze.x + ze.width, coordenadas.y + ze.y + ze.height/2);
					}else {
						if(!tutoPhase) balao.visible = false;
					}
					break;
				
				default:
					return;
			}
		}
		
		private var raioNumber:Number;
		private function drawCilinder(raioCilindro:Number):void
		{
			var materialCylinder:ColorMaterial = new ColorMaterial(0xFF0000, 0.25);
			materialCylinder.doubleSided = true;
			
			if (cilindro != null) {
				scene.removeChild(cilindro);
				cilindro = null;
			}
			
			if (raio.text == "") {
				raioNumber = Number.NaN;
				return;
			}
			
			cilindro = new Cylinder(materialCylinder, raioCilindro, eixos.maxDist, 20, 6, -1, false, false);
			scene.addChild(cilindro);
			raioNumber = raioCilindro;
			
			cilindro.z = -eixos.maxDist / 2;
			cilindro.rotationX = 90;
			
		}
		
		private var anguloTeta:Number;
		private function drawPlane(angulo:Number):void
		{
			var material:ColorMaterial = new ColorMaterial(0x0000FF, 0.25);
			material.doubleSided = true;
			
			if (planeTeta != null) 
			{
				planeTeta.removeChild(planeTetaInside);
			}
			else
			{
				planeTeta = new DisplayObject3D();
				scene.addChild(planeTeta);
			}
			
			var raioCilindro:Number;
			if (raio.text != "") raioCilindro = Number(raio.text);
			else raioCilindro = 25;
			
			planeTetaInside = new Plane(material, Math.SQRT2*(raioCilindro + 2.5), eixos.maxDist, 10, 10);
			
			planeTeta.addChild(planeTetaInside);
			
			planeTetaInside.x = Math.SQRT2 * (raioCilindro + 2.5) / 2;
			
			
			
			if (planeTeta.rotationX != 90) 
			{
				planeTeta.rotationX = 90;
				//planeTeta.x = 15;
				planeTeta.y = 0;
				planeTeta.z = -eixos.maxDist / 2;
			}
			planeTeta.rotationZ = angulo;
			anguloTeta = angulo;
			
			drawIntersections();
			drawPlanesIntersection();
			
		}
		
		private function drawPlaneZ(coordenada:Number):void
		{
			var material:ColorMaterial = new ColorMaterial(0x00FF00, 0.25);
			material.doubleSided = true;
			
			if (planeZ != null)
			{
				scene.removeChild(planeZ);
			}
			
			var raioCilindro:Number;
			if (raio.text != "") raioCilindro = Number(raio.text);
			else raioCilindro = 25;
			
			planeZ = new Plane(material, (2 * raioCilindro) + 5, (2 * raioCilindro) + 5, 10, 10);
			scene.addChild(planeZ);
			
			planeZ.z = -coordenada;
			
			drawRoundIntersection();
			drawPlanesIntersection();
		}
		
		private function drawIntersections():void
		{
			if (linesInter == null)
			{
				linesInter = new Lines3D();
				
				planeTeta.addChild(linesInter);
				linesInter.rotationX = 90;
				linesInter.y = -eixos.maxDist / 2;
				//linesContainer.addChild(linesInter);
				//scene.addChild(linesContainer);
				
				var portLayerLines2:ViewportLayer = viewport.getChildLayer(linesInter);
				portLayerLines2.forceDepth = true;
				portLayerLines2.screenDepth = 1;
			}
			else linesInter.removeAllLines();
			
			if (raio.text == "") return;
			
			var raioCilindro:Number;
			if (raio.text != "") raioCilindro = Number(raio.text);
			else raioCilindro = 25;
			
			var lineMaterial:LineMaterial = new LineMaterial(0x000000);
			
			var linhaIni:Vertex3D;
			var linhaFim:Vertex3D;
			var linha:Line3D;
			
			for (var i:int = 0; i < eixos.maxDist; i=i+2)
			{
				//X e Y
				linhaIni = new Vertex3D(raioCilindro, 0, -i);
				linhaFim = new Vertex3D(raioCilindro, 0, -i-1);
				linha = new Line3D(linesInter, lineMaterial, 1, linhaIni, linhaFim);
				linesInter.addLine(linha);
			}
			
		}
		
		private function drawPoint():void
		{
			if (raio.text == "" || teta.text == "" || ze.text == "") {
				interLetter = null;
				planeTeta.removeChild(intersecao);
				intersecao = null;
				scene.removeChild(containerP);
				containerP = null;
				return;
			}
			
			var interMaterial:FlatShadeMaterial = new FlatShadeMaterial(null, 0x000000, 0x000000);
			
			if(intersecao == null)
			{
				intersecao = new Sphere(interMaterial, 0.5);
				planeTeta.addChild(intersecao);
			}
			
			var portLayerInter:ViewportLayer = viewport.getChildLayer(intersecao);
			portLayerInter.forceDepth = true;
			portLayerInter.screenDepth = 1;
			
			intersecao.x = Number(raio.text);
			intersecao.y = (eixos.maxDist / 2) - Number(ze.text);
			//intersecao.z = -Number(ze.text);
			
			if (interLetter == null) 
			{
				var letterMaterial:Letter3DMaterial = new Letter3DMaterial(0x000000);
				letterMaterial.doubleSided = true;
				
				var fonte:Font3D = new HelveticaBold();
				
				var ponto:String = "P";
				
				interLetter = new Text3D(ponto, fonte, letterMaterial);
				
				containerP = new DisplayObject3D();
				
				containerP.addChild(interLetter);
				scene.addChild(containerP);
				containerP.scale = 0.025;
				
				interLetter.rotationY = 180;
				
			}
			if (Number(teta.text) >= 0 && Number(teta.text) <= 90)
			{
				containerP.x = Number(raio.text) * Math.cos(Number(teta.text) * Math.PI/180) + 2.5;
				containerP.y = Number(raio.text) * Math.sin(Number(teta.text) * Math.PI / 180) + 2.5;
			}
			else if (Number(teta.text) > 90 && Number(teta.text) <= 180)
			{
				containerP.x = Number(raio.text) * Math.cos(Number(teta.text) * Math.PI/180) - 2.5;
				containerP.y = Number(raio.text) * Math.sin(Number(teta.text) * Math.PI / 180) + 2.5;
			}
			else if (Number(teta.text) > 180 && Number(teta.text) <= 270)
			{
				containerP.x = Number(raio.text) * Math.cos(Number(teta.text) * Math.PI/180) - 2.5;
				containerP.y = Number(raio.text) * Math.sin(Number(teta.text) * Math.PI / 180) - 2.5;
			}
			else
			{
				containerP.x = Number(raio.text) * Math.cos(Number(teta.text) * Math.PI/180) + 2.5;
				containerP.y = Number(raio.text) * Math.sin(Number(teta.text) * Math.PI / 180) - 2.5;
			}
			containerP.z = -Number(ze.text);
			
			lookAtP();
			
		}
		
		/**
		 * @private
		 * Interseção entre PlaneZ e o cilindro.
		 */
		private function drawRoundIntersection():void
		{
			
			if (lines == null)
			{
				lines = new Lines3D();
				scene.addChild(lines);
				
				var portLayerLines:ViewportLayer = viewport.getChildLayer(lines);
				portLayerLines.forceDepth = true;
				portLayerLines.screenDepth = 1;
			}
			else lines.removeAllLines();
			
			if (raio.text == "") return;
			
			var lineMaterial:LineMaterial = new LineMaterial(0x000000);
			
			var linhaIni:Vertex3D;
			var linhaFim:Vertex3D;
			var linha:Line3D;
			
			/*var nTracos:int = 60;
			var anguloTraco:Number = 2 * Math.PI / (nTracos - 1);
			var raio:Number = Number(raio.text);
			
			for (var i:int = 0; i < 360; i+=10)
			{
				linhaIni = new Vertex3D(raio*Math.cos((anguloTraco - i)*Math.PI/180), raio*Math.sin((anguloTraco - i)*Math.PI/180), -Number(ze.text));
				linhaFim = new Vertex3D(raio*Math.cos((anguloTraco - i+5)*Math.PI/180), raio*Math.sin((anguloTraco - i+5)*Math.PI/180), -Number(ze.text));
				linha = new Line3D(lines, lineMaterial, 1, linhaIni, linhaFim);
				lines.addLine(linha);
				
			}*/
			var maxSeg:int = 120;
			var minSeg:int = 10;
			var raioMax:int = 30;
			
			var nTracos:int = Math.round(minSeg + (maxSeg - minSeg) / raioMax * Number(raio.text));
			if (nTracos % 2 == 0) ++nTracos;
			
			var anguloTraco:Number;
			//var raio:Number = Number(raio.text);
			var raioCilindro:Number;
			if (raio.text != "") raioCilindro = Number(raio.text);
			else raioCilindro = 25;
			
			with (Math)
			{
				for (var n:int = 0; n < nTracos; n+= 2)
				{
					
					anguloTraco = 2 * PI * n/ (nTracos - 1);
					anguloTraco2 = 2 * PI * (n + 1)/ (nTracos - 1);
					
					linhaIni = new Vertex3D(raioCilindro*cos(anguloTraco), raioCilindro*sin(anguloTraco), -Number(ze.text));
					linhaFim = new Vertex3D(raioCilindro*cos(anguloTraco2), raioCilindro*sin(anguloTraco2), -Number(ze.text));
					linha = new Line3D(lines, lineMaterial, 1, linhaIni, linhaFim);
					lines.addLine(linha);
					
				}
			}
			
		}
		
		private function drawPlanesIntersection():void
		{
			if (planeZ != null && planeTeta != null)
			{
				if (interPlaneLines == null)
				{
					interPlaneLines = new Lines3D();
					
					planeTeta.addChild(interPlaneLines);
					
					var portLayerLines:ViewportLayer = viewport.getChildLayer(interPlaneLines);
					portLayerLines.forceDepth = true;
					portLayerLines.screenDepth = 1;
				}
				else interPlaneLines.removeAllLines();
				
				var lineMaterial:LineMaterial = new LineMaterial(0x000000);
				
				var linhaIni:Vertex3D;
				var linhaFim:Vertex3D;
				var linha:Line3D;
				
				var raioCilindro:Number;
				if (raio.text != "") raioCilindro = Number(raio.text);
				else raioCilindro = 25;
				
				if ((Number(teta.text) >= 315 && Number(teta.text) <= 360) || (Number(teta.text) >= 0 && Number(teta.text) <= 45) ||(Number(teta.text) >= 135 && Number(teta.text) <= 225)) var comprimento:Number = Math.abs(Math.floor(((2 * raioCilindro + 5) / 2) / Math.cos(Number(teta.text) * Math.PI / 180)));
				else if (Number(teta.text) > 45 && Number(teta.text) < 90) comprimento = Math.abs(Math.floor(((2 * raioCilindro + 5) / 2) / Math.cos((90 - Number(teta.text)) * Math.PI / 180)));
				else if (Number(teta.text) >= 90 && Number(teta.text) < 135) comprimento = Math.abs(Math.floor(((2 * raioCilindro + 5) / 2) / Math.cos((Number(teta.text) - 90) * Math.PI / 180)));
				else if (Number(teta.text) > 225 && Number(teta.text) < 270) comprimento = Math.abs(Math.floor(((2 * raioCilindro + 5) / 2) / Math.sin(Number(teta.text) * Math.PI / 180)));
				else if(Number(teta.text) >= 270 && Number(teta.text) < 315) comprimento = Math.abs(Math.floor(((2 * raioCilindro + 5) / 2) / Math.sin(Number(teta.text) * Math.PI / 180)));
				trace("comprimento: " + comprimento);
				
				for (var i:int = 0; i < comprimento; i=i+2)
				{
					//X e Y
					linhaIni = new Vertex3D(i, (eixos.maxDist / 2) - Number(ze.text), 0);
					linhaFim = new Vertex3D(i+1, (eixos.maxDist / 2) - Number(ze.text), 0);
					linha = new Line3D(linesInter, lineMaterial, 1, linhaIni, linhaFim);
					interPlaneLines.addLine(linha);
				}
				
				drawPoint();
				
			}
		}
		
		private function lookAtP():void 
		{
			if(containerP != null) containerP.lookAt(camera, upVector);
			
			eixos.text3dX.lookAt(camera, upVector);
			eixos.text3dY.lookAt(camera, upVector);
			eixos.text3dZ.lookAt(camera, upVector);
			
			eixos.text10x.lookAt(camera, upVector);
			eixos.text10y.lookAt(camera, upVector);
			eixos.text10z.lookAt(camera, upVector);
		}
		
		public var theta2:Number = -2.4188; 
		public var phi2:Number = 10.4537;
		private function initRotation(e:MouseEvent):void 
		{
			if (e.target is TextField || e.target is CaixaTexto) return;
			//{
				clickPoint.x = stage.mouseX;
				clickPoint.y = stage.mouseY;
				stage.addEventListener(Event.ENTER_FRAME, rotating);
				stage.addEventListener(MouseEvent.MOUSE_UP, stopRotating);
			//}
		}
		
		private function rotating(e:Event):void 
		{
			if(e != null){
				var deltaTheta:Number = (stage.mouseX - clickPoint.x) * Math.PI / 180;
				var deltaPhi:Number = (stage.mouseY - clickPoint.y) * Math.PI / 180;
				
				theta2 -= deltaTheta;
				phi2 -= deltaPhi;
				
			
				clickPoint = new Point(stage.mouseX, stage.mouseY);
			}
			
			camera.x = distance * Math.cos(theta2) * Math.sin(phi2);
			camera.y = distance * Math.sin(theta2) * Math.sin(phi2);
			camera.z = distance * Math.cos(phi2);
			
			look();
			lookAtP();
		}
		
		private function stopRotating(e:MouseEvent):void 
		{
			stage.removeEventListener(Event.ENTER_FRAME, rotating);
			stage.removeEventListener(MouseEvent.MOUSE_UP, stopRotating);
			//trace(theta2, phi2);
		}
		
		public function look():void {
			if (Math.sin(phi2) < 0) upVector = new Number3D(0, 0, -1);
			else upVector = new Number3D(0, 0, 1);
			
			camera.lookAt(eixos, upVector);
		}
		
		private function resetCamera(e:MouseEvent):void
		{
			theta2 = -2.4188;
			phi2 = 10.4537;
			
			zoom = 40;
			this.camera.zoom = zoom;
			
			rotating(null);
			
			initCampos();
			
			lookAtP();
			balao.visible = false;
			tutoPhase = false;
			verifyZoomBtns();
			
		}
		
	}
}