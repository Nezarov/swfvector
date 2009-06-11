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
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;	

	/**
	 * ...
	 * @author guojian@wu-media.com | guojian.wu@ogilvy.com
	 */
	public class SWFParser {
		
		public function SWFParser(data:ByteArray) {
			if ( data ) {
				data.position = 0;
				var header:String = data.readUTFBytes(3);
				_version = data.readUnsignedByte();
				_size = data.readUnsignedInt();
				_data = new Data(data);
				if ( header == "CWS" ) {
					var tmp:ByteArray = new ByteArray();
					_data.readBytes( tmp );
					tmp.position = 0;
					tmp.uncompress();
					tmp.position = 0;
					_data = new Data(tmp);
				}
				_rect = _data.readRect();
				_frameRate = _data.readUnsignedShort() >> 8;
				_frames = _data.readShort();
			}
		}
		
		protected var _data			:Data;
		protected var _version		:uint;
		protected var _size			:uint;
		protected var _rect			:Rectangle;
		protected var _frameRate	:uint;
		protected var _frames		:uint;
		
		public function parseTags(type:*, includeContent:Boolean, endTag:uint = 0, source:Data = null):Array {
			if ( source == null ) {
				source = _data;
			}
			var tagType:int = -1;
			var tagLength:uint;
			var tagPosition:uint;
			var bpos:uint = source.position;
			var tags:Array = [];
			var tag:Tag;
			while ( source.bytesAvailable && tagType != endTag ) {
				tagType = source.readUnsignedShort();
				tagLength = tagType & 0x3f;
				if ( tagLength == 0x3f ) {
					tagLength = source.readUnsignedInt();
				}
				tagType >>= 6;
				tagPosition = source.position;
				if ( tagType == type || (type is Array ? (type as Array).indexOf(tagType) != -1 : false) ) {
					tag = new Tag(tagType, source.position, tagLength);
					if ( includeContent ) {
						var content:ByteArray = new ByteArray();
						source.readBytes(content, 0, tag.length);
						content.position = 0;
						tag.data = new Data(content);
					}
					tags.push( tag );
				}
				if ( source.position == tagPosition ) {
					source.position += tagLength;	
				}
			}
			source.position = bpos;
			return tags;
		}
		
		
		public function get data()		:Data { return _data; }
		public function get ver()		:uint { return _version; }
		public function get size()		:uint { return _size; }
		public function get rect()		:Rectangle { return _rect; }
		public function get frameRate()	:uint { return _frameRate; }
		public function get frames()	:uint {	return _frames;}
	}
}