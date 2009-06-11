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
	import flash.geom.Matrix;	
	/**
	 * ...
	 * @author guojian@wu-media.com
	 */
	public class SWFMatrix extends Matrix {
		
		public function SWFMatrix(data:SWFData) {
			var scaleX:Number;
			var scaleY:Number;
			var rotate0:Number;
			var rotate1:Number;
			var translateX:Number;
			var translateY:Number;
			var bits:uint;
			data.synchBits();
			if ( data.readUBits(1) == 1) {
				bits = data.readUBits(5);
				scaleX = data.readSBits(bits) / 65536.0;
				scaleY = data.readSBits(bits) / 65536.0;
			} else {
				scaleX = 1;
				scaleY = 1;
			}
			if ( data.readUBits(1) == 1) {
				bits = data.readUBits(5);
				rotate0 = data.readSBits(bits) / 65536.0;
				rotate1 = data.readSBits(bits) / 65536.0;
			} else {
				rotate0 = 0;
				rotate1 = 0;
			}
			bits = data.readUBits(5);
			translateX = data.readSBits(bits) * 0.05;
			translateY = data.readSBits(bits) * 0.05;
			
			super(scaleX, rotate0, rotate1, scaleY, translateX, translateY);
		}
		
	}
	
}