﻿/*
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
	import flash.utils.ByteArray;
	import flash.geom.Rectangle;	

	/**
	 * ...
	 * @author guojian@wu-media.com
	 */
	public class SWFDefineFont {
		
		public function SWFDefineFont(tag:SWFTag) {
			_data = tag.data;
			_tagType = tag.type;
			_ascent = 0;
			_descent = 0;
			_leading = 0;
			if ( _data ) {
				parse();
			}
		}
		
		private var _data		:SWFData;
		private var _tagType	:uint;
		private var _flags		:uint;
		private var _name		:String;
		private var _ascent		:Number;
		private var _descent	:Number;
		private var _leading	:Number;
		private var _numGlyphs	:uint;
		private var _shapes		:Array;
		private var _glyphs		:Object;
		private var _advances	:Object;
		private var _top		:Number;
		private var _bottom		:Number;
		
		
		private function parse():void {
			var i:int;
			var gSize:uint;
			var nLen:uint;
			var offsets:Array;
			var off32:Boolean;
			
			_glyphs = { };
			_advances = { };
			_top = Number.POSITIVE_INFINITY;
			_bottom = Number.NEGATIVE_INFINITY;
			
			_data.position += 2;	// id
			_flags = _data.readUnsignedByte();
			_data.position += 1;	// language
			nLen = _data.readUnsignedByte();
			_name = _data.readUTFBytes(nLen);
			_numGlyphs = _data.readUnsignedShort();
			
			offsets = new Array(_numGlyphs + 1);
			off32 = (_flags & 0x08) != 0;
			for ( i = 0; i <= _numGlyphs; ++i ) {
				offsets[i] = off32 ? _data.readUnsignedInt() : _data.readUnsignedShort();
			}
			
			_shapes = new Array(_numGlyphs);
			for ( i = 1; i <= _numGlyphs; ++i ) {
				gSize = offsets[i] - offsets[i - 1];
				var bytes:ByteArray = new ByteArray();
				_data.readBytes(bytes, 0, gSize);
				bytes.position = 0;
				_shapes[i - 1] = new SWFShapeRecord(new SWFData(bytes), _tagType);
			}
			var chars:Array = new Array(_numGlyphs);
			for ( i = 0; i < _numGlyphs; ++i ) {
				var char:String = String.fromCharCode(_data.readUnsignedShort());
				var shape:SWFShapeRecord = _shapes[i];
				_glyphs[char] = shape;
				chars[i] = char;
				if ( char > "A" && char < "Z" ) {
					if ( shape.bounds.top < _top ) {
						_top = shape.bounds.top;
					}
				}
				if ( shape.bounds.bottom > _bottom ) {
					_bottom = shape.bounds.bottom;
				}
			}
			var hasStyles:Boolean = (_flags & 0x80) != 0;
			if ( hasStyles ) {
				_ascent = _data.readShort() * 0.05;
				_descent = _data.readShort() * 0.05;
				_leading = _data.readShort() * 0.05;
				for ( i = 0; i < _numGlyphs; ++i ) {
					_advances[chars[i]] = _data.readShort() * 0.05;
				}
				/*
				// not being used at the moment
				// bounds
				for ( i = 0; i < _numGlyphs; ++i ) {
					new SWFRect(_data);
				}
				var kerningCount:uint = _data.readUnsignedShort();
				for ( i = 0; i < kerningCount; ++i ) {
					new SWFKerningRecord(_data, (flags & 0x04) != 0);
				}
				*/
			}
			
		}
		
		public function get name():String { return _name; }
		public function get ascent():Number { return _ascent; }
		public function get descent():Number { return _descent; }
		public function get leading():Number { return _leading; }
		public function get glyphs():Object { return _glyphs; }
		public function get advances():Object { return _advances; }
		public function get isBold():Boolean { return (_flags & 0x01) != 0; }
		public function get isItalic():Boolean { return (_flags & 0x02) != 0; }
		public function get isBoldItalic():Boolean { return isBold && isItalic; }
		public function get isRegular():Boolean { return !isBold && !isItalic; }
		public function get top():Number { return _top; }
		public function get bottom():Number { return _bottom; }
	}
}