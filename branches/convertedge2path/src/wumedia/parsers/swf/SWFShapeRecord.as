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
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.geom.Rectangle;	

	/**
	 * ...
	 * @author guojian@wu-media.com
	 */
	public class SWFShapeRecord {
		static private var _shape	:Shape = new Shape();
		
		static public function drawShape(graphics:*, shape:SWFShapeRecord, scale:Number = 1.0, offsetX:Number = 0.0, offsetY:Number = 0.0):void {
			var elems:Array = shape.elements;
			var elemNum:int = -1;
			var elemLen:int = elems.length;
			var lastFill:SWFGraphicsElement;
			trace("\n\n")
			while ( ++elemNum < elemLen ) {
				if ( elems[elemNum] is SWFGraphicsElement ) {
					if ( lastFill != elems[elemNum] ) {
						elems[elemNum].apply(graphics, scale, offsetX, offsetY);
						trace(elems[elemNum])
					}
					lastFill = elems[elemNum];
				} else if ( elems[elemNum] is Array )  {
					var a:Array = elems[elemNum];
					trace(a);
					switch( a[0] ) {
						case "M":
							graphics["moveTo"](offsetX + a[1] * scale, offsetY + a[2] * scale);
							break;
						case "L":
							graphics["lineTo"](offsetX + a[1] * scale, offsetY + a[2] * scale);
							break;
						case "C":
							graphics["curveTo"](offsetX + a[1] * scale, offsetY + a[2] * scale, offsetX + a[3] * scale, offsetY + a[4] * scale);
							break;
					}
				}
			}
		}
		
		public function SWFShapeRecord(data:SWFData, tagType:uint) {
			_tagType = tagType;
			_hasStyle = _tagType == SWFTagTypes.DEFINE_SHAPE
						|| _tagType == SWFTagTypes.DEFINE_SHAPE2
						|| _tagType == SWFTagTypes.DEFINE_SHAPE3
						|| _tagType == SWFTagTypes.DEFINE_SHAPE4;
			_hasAlpha = _tagType == SWFTagTypes.DEFINE_SHAPE3
						|| _tagType == SWFTagTypes.DEFINE_SHAPE4;
			_hasExtendedFill = _tagType == SWFTagTypes.DEFINE_SHAPE2
						|| _tagType == SWFTagTypes.DEFINE_SHAPE3
						|| _tagType == SWFTagTypes.DEFINE_SHAPE4;
			_hasStateNewStyle = _tagType == SWFTagTypes.DEFINE_SHAPE2
						|| _tagType == SWFTagTypes.DEFINE_SHAPE3;
			parse(data);
//			if ( _elements.length > 0 ) {
//				calculateBounds();
//			} else {
//				_bounds = new Rectangle(0, 0, 0, 0);
//			}
		}
		
		private var _tagType				:uint;
		private var _fillBits				:uint;
		private var _lineBits				:uint;
		private var _hasStyle				:Boolean;
		private var _hasAlpha				:Boolean;
		private var _hasExtendedFill		:Boolean;
		private var _hasStateNewStyle		:Boolean;
		private var _elements				:Array;
		private var _bounds					:Rectangle;
		private var _fills					:Array;
		private var _lines					:Array;
		
		private function parse(data:SWFData):void {
			var stateMoveTo:Boolean;
			var stateFillStyle0:Boolean;
			var stateFillStyle1:Boolean;
			var stateLineStyle:Boolean;
			var stateNewStyles:Boolean;
			var fillStyle0:int;
			var fillStyle1:int;
			var lineStyle:int;
			var flags:uint;
			var dx:Number = 0;
			var dy:Number = 0;
			var elemCurve:SWFGraphicsCurve;
			var elemLine:SWFGraphicsLine;
			var elemMove:SWFGraphicsMove;
			var fill0:Array;
			var fill1:Array;
			var lastMove:Array;
			_elements = new Array();
			_fills = new Array();
			_lines = new Array();
			data.synchBits();
			if ( _hasStyle ) {
				parseStyles(data);
				data.synchBits();
			}
			_fillBits = data.readUBits(4);
			_lineBits = data.readUBits(4);
			while ( true ) {
				var type:uint = data.readUBits(1);
				if ( type == 1 ) {
					// Edge shape-record
					if ( data.readUBits(1) == 0 ) {
						elemCurve = new SWFGraphicsCurve(data, dx, dy);
						trace("C", elemCurve.cx, elemCurve.cy, elemCurve.ax, elemCurve.ay)
						if ( fill0 ) {
							fill0.push(["C", elemCurve.cx, elemCurve.cy, elemCurve.ax, elemCurve.ay]);
						}
						if ( fill1 ) {
							fill1.push(["C", elemCurve.cx, elemCurve.cy, elemCurve.ax, elemCurve.ay]);
						}
						dx = elemCurve.ax;
						dy = elemCurve.ay;
					} else {
						elemLine = new SWFGraphicsLine(data, dx, dy);
						trace("L", elemLine.dx, elemLine.dy);
						if ( fill0 ) {
							fill0.push(["L", elemLine.dx, elemLine.dy]);
						}
						if ( fill1 ) {
							fill1.push(["L", elemLine.dx, elemLine.dy]);
						}
						dx = elemLine.dx;
						dy = elemLine.dy;
					}
					lastMove = null;
				} else {
					// Change Record or End
					flags = data.readUBits(5);
					if ( flags == 0 ) {
						// end
						break;
					}
					stateMoveTo = (flags & 0x01) != 0;
					stateFillStyle0 = (flags & 0x02) != 0;
					stateFillStyle1 = (flags & 0x04) != 0;
					stateLineStyle = (flags & 0x08) != 0;
					stateNewStyles = (flags & 0x10) != 0;
					if ( stateMoveTo ) {
						elemMove = new SWFGraphicsMove(data);
						dx = elemMove.x;
						dy = elemMove.y;
						lastMove = ["M", dx, dy];
						trace(lastMove)
						if ( fill0 ) {
							fill0.push(["M", dx, dy]);
						}
						if ( fill1 ) {
							fill1.push(["M", dx, dy]);
						}
					}
					if ( stateFillStyle0 ) {
						fillStyle0 = data.readUBits(_fillBits);
					}
					if ( stateFillStyle1 ) {
						fillStyle1 = data.readUBits(_fillBits);
					}
					if ( stateLineStyle ) {
						lineStyle = data.readUBits(_lineBits);
					}
					if ( _hasStyle ) {
						if ( fillStyle0 > 0 && _fills[fillStyle0 - 1] ) {
							trace("fill 0", fillStyle0 - 1);
							fill0 = _fills[fillStyle0 - 1];
							fill0.push(["M", dx, dy]);
						} else {
							fill0 = null;
						}
						if ( fillStyle1 > 0 && _fills[fillStyle1 - 1] ) {
							trace("fill 1", fillStyle1 - 1);
							fill1 = _fills[fillStyle1 - 1];
							fill1.push(["M", dx, dy]);
						} else {
							fill1 = null;
						}
						
						
					}
					if ( _hasStateNewStyle && stateNewStyles ) {
						parseStyles(data);
						_fillBits = data.readUBits(4);
						_lineBits = data.readUBits(4);
					}
				}
			}
			saveElements();
		}
		

		private function parseStyles(data:SWFData):void {
			var i:int;
			var num:int;
			saveElements();
			
			num = data.readUnsignedByte();
			if ( _hasExtendedFill && num == 0xff ) {
				num = data.readUnsignedShort();
			}
			for ( i = 0; i < num; ++i ) {
				_fills.push([new SWFGraphicsFillStyle(data, _hasAlpha)]);
			}
			trace("fillArray");
			_fills.every(function(ele:Array,...args):Boolean { trace(ele); return true; } );
			trace("\n")
			
			num = data.readUnsignedByte();
			if ( num == 0xff ) {
				num = data.readUnsignedShort();
			}
			for ( i = 0; i < num; ++i ) {
				if ( _tagType == SWFTagTypes.DEFINE_SHAPE4 ) {
					_lines.push([new SWFGraphicsLineStyle2(data, _hasAlpha, _tagType)]);
				} else {
					_lines.push([new SWFGraphicsLineStyle(data, _hasAlpha)]);
				}
			}
		}
		
		private function saveElements():void {
			var i:int;
			var l:int;
			l = _fills.length;
			i = -1;
			while ( ++i < l ) {
				_elements = _elements.concat(_fills[i]);
			}
			_fills = new Array();
			_lines = new Array();
		}
		
		private function calculateBounds():void {
			var g:Graphics = _shape.graphics;
			g.clear();
			g.beginFill(0);
			drawShape(g, this);
			g.endFill();
			_bounds = _shape.getRect(_shape);
		}
		
		public function get elements():Array { return _elements; }
		public function get bounds():Rectangle { return _bounds; }
	}
	
}