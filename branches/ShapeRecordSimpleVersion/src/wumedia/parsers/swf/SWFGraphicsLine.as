/*
 * Copyright 2009 (c) Guojian Miguel Wu, guojian@wu-media.com.
 *
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use,
 * copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following
 * conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 */
package wumedia.parsers.swf {
	/**
	 * ...
	 * @author guojian@wu-media.com
	 */
	public class SWFGraphicsLine extends SWFGraphicsElement {
		
		public function SWFGraphicsLine(data:SWFData, offsetX:Number = 0.0, offsetY:Number = 0.0) {
			var numBits:uint = data.readUBits(4) + 2;
			var generaLine:Boolean = data.readUBits(1) == 1;
			if ( generaLine ) {
				_dx = data.readSBits(numBits) * 0.05 + offsetX;
				_dy = data.readSBits(numBits) * 0.05 + offsetY;
			} else {
				var isVertical:Boolean = data.readUBits(1) == 1;
				if ( isVertical ) {
					_dx = offsetX;
					_dy = data.readSBits(numBits) * 0.05 + offsetY;
				} else {
					_dx = data.readSBits(numBits) * 0.05 + offsetX;
					_dy = offsetY;
				}
			}
			_type = "L";
		}
		
		private var _dx:Number;
		private var _dy:Number;
		
		override public function apply(graphics:*, scale:Number = 1.0, offsetX:Number = 0.0, offsetY:Number = 0.0):void {
			graphics.lineTo(offsetX + _dx * scale, offsetY + _dy * scale);
		}
		
		override public function toString():String {
			return ["L", _dx, _dy].join(", ");
		}

		public function get dx():Number { return _dx; }
		public function get dy():Number { return _dy; }
		public function set dx(dx : Number) : void { _dx = dx; }
		public function set dy(dy : Number) : void { _dy = dy; }
	}
}