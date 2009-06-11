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
	 * ...
	 * @author guojian@wu-media.com | guojian.wu@ogilvy.com
	 */
	public class KerningRecord {
		
		public function KerningRecord(data:Data, wideCodes:Boolean) {
			_kerningCode0 = wideCodes ? data.readUnsignedShort() : data.readUnsignedByte();
			_kerningCode1 = wideCodes ? data.readUnsignedShort() : data.readUnsignedByte();
			_kerningChar0 = String.fromCharCode(kerningCode0);
			_kerningChar1 = String.fromCharCode(kerningCode1);
			_kerningAdjustment = data.readShort();
		}
		
		private var _kerningCode0 		:uint;
		private var _kerningCode1 		:uint;
		private var _kerningChar0		:String;
		private var _kerningChar1		:String;
		private var _kerningAdjustment	:uint;
		public function get kerningCode0():uint { return _kerningCode0; }
		public function get kerningCode1():uint { return _kerningCode1; }
		public function get kerningAdjustment():uint { return _kerningAdjustment; }
		public function get kerningChar0():String { return _kerningChar0; }
		public function get kerningChar1():String { return _kerningChar1; }
		
		
	}
	
}