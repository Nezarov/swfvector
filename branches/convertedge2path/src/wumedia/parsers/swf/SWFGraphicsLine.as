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
		
		public function SWFGraphicsLine(data:SWFData, offsetX:int = 0.0, offsetY:int = 0.0) {
			var numBits:uint = data.readUBits(4) + 2;
			var generaLine:Boolean = data.readUBits(1) == 1;
			sx = offsetX;
			sy = offsetY;
			if ( generaLine ) {
				x = data.readSBits(numBits) + offsetX;
				y = data.readSBits(numBits) + offsetY;
			} else {
				var isVertical:Boolean = data.readUBits(1) == 1;
				if ( isVertical ) {
					x = offsetX;
					y = data.readSBits(numBits) + offsetY;
				} else {
					x = data.readSBits(numBits) + offsetX;
					y = offsetY;
				}
			}
			_type = "L";
		}
		
		public var sx:int;		public var sy:int;
		public var x:int;
		public var y:int;
		
		override public function apply(graphics:*, scale:Number = 1, offsetX:Number = 0.0, offsetY:Number = 0.0):void {
			graphics.lineTo(x * scale + offsetX, y * scale + offsetY);
		}

	}
}