package test {	import five3D.display.Scene3D;
	import five3D.display.Shape3D;
	
	import wumedia.vector.VectorText;
	
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.text.Font;	
	/**	 * @author guojian@wu-media.com | guojian.wu@ogilvy.com	 */	public class TestFive3D extends Sprite {		public function TestFive3D() {			if (stage) init();			else addEventListener(Event.ADDED_TO_STAGE, init);		}				private var _world	:Sprite;		private var _text	:Shape3D;				private function init(e:Event = null):void {			removeEventListener(Event.ADDED_TO_STAGE, init);			stage.scaleMode = StageScaleMode.NO_SCALE;			stage.align = StageAlign.TOP_LEFT;						Font.registerFont(Font1);			VectorText.extractFont(root.loaderInfo.bytes,  null, true);						var scene:Scene3D = new Scene3D();			_world = new Sprite();			_world.addChild(scene);			addChild(_world);									_text = new Shape3D();			_text.rotationX = 30;			_text.rotationY = 30;			_text.rotationZ = 30;			scene.addChild(_text);						_text.graphics3D.beginFill(0xff4400);			VectorText.write(_text.graphics3D, "_Verdana", 40, 40, 0, "Hello five3D World\nYour fontz are embedded!", 0, 0, Number.POSITIVE_INFINITY, VectorText.CENTER);									addEventListener(Event.ENTER_FRAME, onFrame);			stage.addEventListener(Event.RESIZE, update);			update();		}				private function onFrame(e:Event):void {			_text.rotationY += 2;		}				private function update(e:Event = null):void {			_world.x = stage.stageWidth * .5;			_world.y = stage.stageHeight * .5;
		}	}}