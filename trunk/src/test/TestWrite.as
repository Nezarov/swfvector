package test {
	import wumedia.vector.VectorText;

	import flash.display.GradientType;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.text.Font;
	import flash.utils.getTimer;

	/**
	 * @author guojian@wu-media.com | guojian.wu@ogilvy.com
	 */
	public class TestWrite extends Sprite {
		
		public function TestWrite():void {
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			Font.registerFont(Font0);			Font.registerFont(Font1);
			var t:Number = getTimer();			VectorText.extractFont(root.loaderInfo.bytes, ["_Arial"], true);
			trace("parse time:" + ((getTimer() - t)/ 1000) + "s");
			stage.addEventListener(Event.RESIZE, update);
			update();
		}
		
		private function update(e:Event = null):void {
			var w:Number = stage.stageWidth;
			var h:Number = stage.stageHeight;
			var w2:Number = int(w * .5);			var h2:Number = int(h * .5);
			var m:Matrix = new Matrix();
			m.createGradientBox(w2, 300, 0.03, w2);
			
			
			graphics.clear();
			graphics.beginFill(0xff0000, .1);
			graphics.drawRect(0, h2, w, 1);			graphics.drawRect(w2, 0, 1, h);
			graphics.endFill();
			
			graphics.beginGradientFill(GradientType.LINEAR, [0xff4400, 0x0000ff, 0xff4400], [1, 1, 1], [0x00, 0x77, 0xff], m);
			VectorText.write(graphics, "_Webdings", 20, 20, 0, "Hello World. This text is aligned TOP LEFT on baseline", w2, h2, w2, VectorText.TOP_LEFT, false);			graphics.endFill();
		}
	}
	
}