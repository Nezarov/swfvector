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
	public class Color {
		
		public function Color(data:Data, hasAlpha:Boolean) {
			r = data.readUnsignedByte();
			g = data.readUnsignedByte();
			b = data.readUnsignedByte();
			if ( hasAlpha ) {
				a = data.readUnsignedByte();
			} else {
				a = 0xff;
			}
		}
		
		public var r:uint;
		public var g:uint;
		public var b:uint;
		public var a:uint;

		public function toString():String {
			return value.toString(16); 
		}
		
		public function get value():uint {
			return a << 24 | r << 16 | g << 8 | b;
		}
		
		public function get color():uint {
			return r << 16 | g << 8 | b;
		}
		
		public function get alpha():Number {
			return a / 0xff;
		}
		
	}
	
}