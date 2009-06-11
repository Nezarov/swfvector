/*
 * Copyright 2009 (c) Guojian Miguel Wu, guojian@wu-media.com | guojian.wu@ogilvy.com
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
	 * @author guojian@wu-media.com | guojian.wu@ogilvy.com
	 */
	public class Edge {
		static public const CURVE	:uint = 0;
		static public const LINE	:uint = 1;
		public function Edge(type:uint, data:Data, startX:int = 0.0, startY:int = 0.0) {
			this.type = type;
			if (data) {
				sx = startX;
				sy = startY;
				if (type == CURVE) {
					parseCurve(data);
				} else {
					parseLine(data);
				}
			}
		}
		
		public var type:uint;
		public var cx:int;
		public var cy:int;
		public var sx:int;
		public var sy:int;
		public var x:int;
		public var y:int;
		
		public function reverse():Edge {
			var edge:Edge = new Edge(type, null);
			edge.x = sx;
			edge.y = sy;
			edge.cx = cx;
			edge.cy = cy;
			edge.sx = x;
			edge.sy = y;
			return edge;
		}

		public function apply(graphics:*, scale:Number = 1.0, offsetX:Number = 0.0, offsetY:Number = 0.0):void {
			if (type == CURVE) {
				graphics["curveTo"](cx * scale + offsetX, cy * scale + offsetY, x * scale + offsetX, y * scale + offsetY);
			} else {
				graphics["lineTo"](x * scale + offsetX, y * scale + offsetY);
			}
		}
		
		private function parseLine(data:Data) : void {
			var numBits:uint = data.readUBits(4) + 2;
			var generaLine:Boolean = data.readUBits(1) == 1;
			if ( generaLine ) {
				x = data.readSBits(numBits) + sx;
				y = data.readSBits(numBits) + sy;
			} else {
				var isVertical:Boolean = data.readUBits(1) == 1;
				if ( isVertical ) {
					x = sx;
					y = data.readSBits(numBits) + sy;
				} else {
					x = data.readSBits(numBits) + sx;
					y = sy;
				}
			}
		}

		private function parseCurve(data:Data) : void {
			var numBits:uint = data.readUBits(4) + 2;
			cx = data.readSBits(numBits) + sx;
			cy = data.readSBits(numBits) + sy;
			x = data.readSBits(numBits) + cx;
			y = data.readSBits(numBits) + cy;
		}

	}
}