package  
{
	import flash.display.DisplayObject;
	import org.papervision3d.core.geom.Lines3D;
	import org.papervision3d.core.geom.renderables.Line3D;
	import org.papervision3d.core.geom.renderables.Vertex3D;
	import org.papervision3d.materials.ColorMaterial;
	import org.papervision3d.materials.shadematerials.FlatShadeMaterial;
	import org.papervision3d.materials.special.Letter3DMaterial;
	import org.papervision3d.materials.special.LineMaterial;
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.objects.primitives.Cone;
	import org.papervision3d.typography.Font3D;
	import org.papervision3d.typography.fonts.HelveticaBold;
	import org.papervision3d.typography.Text3D;
	/**
	 * ...
	 * @author Alexandre
	 */
	public class CartesianAxis3D extends DisplayObject3D
	{
		private var eixos:DisplayObject3D;
		
		public var text3dX:DisplayObject3D;
		public var text3dY:DisplayObject3D;
		public var text3dZ:DisplayObject3D;
		
		public var text10x:DisplayObject3D;
		public var text10y:DisplayObject3D;
		public var text10z:DisplayObject3D;
		
		public var maxDist:Number = 50;
		
		public function CartesianAxis3D(withLines:Boolean = false) 
		{
			createEixos();
			createPontas();
			createLegendas();
			createTicks();
			if (withLines) createLines();
		}
		
		private function createEixos():void
		{
			eixos = new DisplayObject3D;
			addChild(eixos);
			
			var linesEixos:Lines3D = new Lines3D();
			eixos.addChild(linesEixos);
			
			var lineMaterialEixos:LineMaterial = new LineMaterial(0x000000);
			var cor:ColorMaterial = new ColorMaterial(0xFF0000);
			
			var eixoXa:Vertex3D = new Vertex3D(0, 0, 0);
			var eixoXb:Vertex3D = new Vertex3D(maxDist, 0, 0);
			var eixoX:Line3D = new Line3D(linesEixos, lineMaterialEixos, 2, eixoXa, eixoXb);
			linesEixos.addLine(eixoX);
			
			var eixoYa:Vertex3D = new Vertex3D(0, 0, 0);
			var eixoYb:Vertex3D = new Vertex3D(0, maxDist, 0);
			var eixoY:Line3D = new Line3D(linesEixos, lineMaterialEixos, 2, eixoYa, eixoYb);
			linesEixos.addLine(eixoY);
			
			var eixoZa:Vertex3D = new Vertex3D(0, 0, 0);
			var eixoZb:Vertex3D = new Vertex3D(0, 0, -maxDist);
			var eixoZ:Line3D = new Line3D(linesEixos, lineMaterialEixos, 2, eixoZa, eixoZb);
			linesEixos.addLine(eixoZ);
		}
		
		private function createPontas():void
		{
			//var cor:ColorMaterial = new ColorMaterial(0x000000);
			var cor:FlatShadeMaterial = new FlatShadeMaterial(null, 0x000000, 0x5D5D5D);
			
			var coneX:Cone = new Cone(cor, 0.7, 3);
			eixos.addChild(coneX);
			coneX.x = maxDist + 1.5;
			coneX.localRotationZ = 90;
			
			var coneY:Cone = new Cone(cor, 0.7, 3);
			eixos.addChild(coneY);
			coneY.y = maxDist + 1.5;
			//coneY.localRotationZ = 90;
			
			var coneZ:Cone = new Cone(cor, 0.7, 3);
			eixos.addChild(coneZ);
			coneZ.z = -maxDist - 1.5;
			coneZ.localRotationX = 90;
		}
		
		private function createLegendas():void
		{
			var letterMaterial:Letter3DMaterial = new Letter3DMaterial(0x000000);
			letterMaterial.doubleSided = true;
			var fonte:Font3D = new HelveticaBold();
			
			var textX:String = "x";
			var textY:String = "y";
			var textZ:String = "z";
			
			text3dX = new DisplayObject3D;
			var textoX:Text3D = new Text3D(textX, fonte, letterMaterial);
			text3dX.addChild(textoX);
			textoX.rotationY = 180;
			
			text3dY = new DisplayObject3D;
			var textoY:Text3D = new Text3D(textY, fonte, letterMaterial);
			text3dY.addChild(textoY);
			textoY.rotationY = 180;
			
			text3dZ = new DisplayObject3D;
			var textoZ:Text3D = new Text3D(textZ, fonte, letterMaterial);
			text3dZ.addChild(textoZ);
			textoZ.rotationY = 180;
			
			eixos.addChild(text3dX);
			text3dX.scale = 0.03;
			text3dX.x = maxDist - 1;
			text3dX.y = -1.5;
			text3dX.z = -1.5;
			
			eixos.addChild(text3dY);
			text3dY.scale = 0.03;
			text3dY.x = -1.5;
			text3dY.y = maxDist - 1;
			text3dY.z = -1.5;
			
			eixos.addChild(text3dZ);
			text3dZ.scale = 0.03;
			text3dZ.x = 0;
			text3dZ.y = -1.5;
			text3dZ.z = -maxDist + 1;
			text3dZ.rotationY = -90;
		}
		
		private function createTicks():void
		{
			var ticks:Lines3D = new Lines3D();
			addChild(ticks);
			
			var tickMaterial:LineMaterial = new LineMaterial(0x000000);
			
			var tickIni:Vertex3D;
			var tickFim:Vertex3D;
			var tick:Line3D;
			
			var nTicks:int = maxDist / 5;
			
			//Ticks eixo X
			for (var i:int = 1; i < nTicks; i++) 
			{
				tickIni = new Vertex3D(i*5, 0, 0);
				tickFim = new Vertex3D(i*5, 0.8, 0);
				
				tick = new Line3D(ticks, tickMaterial, 0.1, tickIni, tickFim);
				ticks.addLine(tick);
			}
			
			//Ticks eixo Y
			for (i = 1; i < nTicks; i++) 
			{
				tickIni = new Vertex3D(0, i*5, 0);
				tickFim = new Vertex3D(0.8, i*5, 0);
				
				tick = new Line3D(ticks, tickMaterial, 0.1, tickIni, tickFim);
				ticks.addLine(tick);
			}
			
			//Ticks eixo Z
			for (i = 1; i < nTicks; i++) 
			{
				tickIni = new Vertex3D(0, 0, -i*5);
				tickFim = new Vertex3D(0, 0.8, -i*5);
				
				tick = new Line3D(ticks, tickMaterial, 0.1, tickIni, tickFim);
				ticks.addLine(tick);
			}
			
			
			//Números 10 nos eixos.
			var letterMaterial:Letter3DMaterial = new Letter3DMaterial(0x000000);
			letterMaterial.doubleSided = true;
			var fonte:Font3D = new HelveticaBold();
			
			var text10:String = "10";
			
			text10x = new DisplayObject3D();
			var texto10x:Text3D = new Text3D(text10, fonte, letterMaterial);
			text10x.addChild(texto10x);
			texto10x.rotationY = 180;
			
			text10y = new DisplayObject3D();
			var texto10y:Text3D  = new Text3D(text10, fonte, letterMaterial);
			text10y.addChild(texto10y);
			texto10y.rotationY = 180;
			
			text10z = new DisplayObject3D();
			var texto10z:Text3D  = new Text3D(text10, fonte, letterMaterial);
			text10z.addChild(texto10z);
			texto10z.rotationY = 180;
			
			addChild(text10x);
			text10x.scale = 0.02;
			text10x.x = 10;
			text10x.y = -1.5;
			text10x.z = 0;
			
			addChild(text10y);
			text10y.scale = 0.02;
			text10y.x = -1.8;
			text10y.y = 10;
			text10y.z = 0;
			
			addChild(text10z);
			text10z.scale = 0.02;
			text10z.x = 0;
			text10z.y = -1.5;
			text10z.z = -10;
			text10z.rotationY = -90;
			
		}
		
		private function createLines():void
		{
			var lines:Lines3D = new Lines3D();
			addChild(lines);
			
			var lineMaterial:LineMaterial = new LineMaterial(0x000000);
			var lineMaterialEixos:LineMaterial = new LineMaterial(0xB4B4B4);
			
			var ev0z:Vertex3D = new Vertex3D(eixos.x, eixos.y, -1000);
			var ev1z:Vertex3D = new Vertex3D(eixos.x, eixos.y, 1000);
			var elineZ:Line3D = new Line3D(lines, lineMaterialEixos, 0.2, ev0z, ev1z);
			lines.addLine(elineZ);
			
			var ev0x:Vertex3D = new Vertex3D(-1000, eixos.y, eixos.z);
			var ev1x:Vertex3D = new Vertex3D(1000, eixos.y, eixos.z);
			var elineX:Line3D = new Line3D(lines, lineMaterialEixos, 0.2, ev0x, ev1x);
			lines.addLine(elineX);
			
			var ev0y:Vertex3D = new Vertex3D(eixos.x, -1000, eixos.z);
			var ev1y:Vertex3D = new Vertex3D(eixos.x, 1000, eixos.z);
			var elineY:Line3D = new Line3D(lines, lineMaterialEixos, 0.2, ev0y, ev1y);
			lines.addLine(elineY);
		}
	}
}