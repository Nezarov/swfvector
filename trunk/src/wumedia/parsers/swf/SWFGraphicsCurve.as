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
	public class SWFGraphicsCurve extends SWFGraphicsElement {
		
		public function SWFGraphicsCurve(data:SWFData, offsetX:Number = 0.0, offsetY:Number = 0.0) {
			var numBits:uint = data.readUBits(4) + 2;
			_cx = data.readSBits(numBits) * 0.05 + offsetX;
			_cy = data.readSBits(numBits) * 0.05 + offsetY;
			_ax = data.readSBits(numBits) * 0.05 + _cx;
			_ay = data.readSBits(numBits) * 0.05 + _cy;
			
			_type = "C";
		}
		
		
		private var _cx:Number;
		private var _cy:Number;
		private var _ax:Number;
		private var _ay:Number;
		
		override public function apply(graphics:*, scale:Number = 1, offfsetX:Number = 0.0, offfsetY:Number = 0.0):void {
			graphics.curveTo(offfsetX + _cx * scale, offfsetY + _cy * scale, offfsetX + _ax * scale, offfsetY + _ay * scale);
		}
		
		override public function toString():String {
			return ["C", _cx, _cy, _ax, _ay].join(", ");
		}

		public function get cx():Number { return _cx; }
		public function get cy():Number { return _cy; }
		public function get ax():Number { return _ax; }
		public function get ay():Number { return _ay; }
		
		public function set cx(cx : Number) : void { _cx = cx; }
		public function set cy(cy : Number) : void { _cy = cy; }
		public function set ax(ax : Number) : void { _ax = ax; }
		public function set ay(ay : Number) : void { _ay = ay; }
	}
}