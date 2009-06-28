package test {
import wumedia.vector.VectorText;

import flash.display.Sprite;
import flash.events.Event;
import flash.net.URLLoader;
import flash.net.URLLoaderDataFormat;
import flash.net.URLRequest;

/**
 * @author lenovo
 */
public class TestLoadFonts extends Sprite {
	public function TestLoadFonts() {
		if ( stage ) {
			init();
		} else {
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
	}
	
	private var _loader:URLLoader;
	private function init(e:Event = null):void {
		removeEventListener(Event.ADDED_TO_STAGE, init);
		_loader = new URLLoader();
		_loader.dataFormat = URLLoaderDataFormat.BINARY;
		_loader.addEventListener(Event.COMPLETE, onLoaded);
		_loader.load(new URLRequest("fonts.swf"));
	}
	
	private function onLoaded(e:Event):void {
		_loader.removeEventListener(Event.COMPLETE, onLoaded);
		VectorText.extractFont(_loader.data, null, true);
		
		graphics.beginFill(0xff9900);
		VectorText.write(graphics, "Zurich Blk BT", 18, 18, 0, "Zurich Blk BT", 0, 0);		VectorText.write(graphics, "Swis721 BT", 18, 18, 0, "Swis721 BT", 0, 25);		VectorText.write(graphics, "Univers 55", 18, 18, 0, "Univers 55", 0, 50);		VectorText.write(graphics, "MetaBoldLFRoman", 18, 18, 0, "MetaBoldLFRoman", 0, 75);		VectorText.write(graphics, "Staccato222 BT", 18, 18, 0, "Staccato222 BT", 0, 100);		VectorText.write(graphics, "Futura Md", 18, 18, 0, "Futura Md", 0, 125);		VectorText.write(graphics, "Webdings", 18, 18, 0, "Webdings", 0, 150);
	}
}
}
