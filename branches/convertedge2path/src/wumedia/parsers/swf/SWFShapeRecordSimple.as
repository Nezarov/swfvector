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
	import flash.display.Graphics;	import flash.display.Shape;	import flash.geom.Rectangle;	
	/**
	 * ...
	 * @author guojian@wu-media.com
	 */
	public class SWFShapeRecordSimple {
		static private var _shape	:Shape = new Shape();
		

		static public function drawShape(graphics:*, data:SWFShapeRecordSimple, scale:Number = 1.0, offsetX:Number = 0.0, offsetY:Number = 0.0):void {
			var group:Array = data.shapesGroup;
			var shapeNum:int = -1;
			var shapeLen:int = group.length;
			var shape:Array;
			var elemNum:int;
			var elemLen:int;
			var elem:SWFGraphicsElement;
			scale *= .05;
			while ( ++shapeNum < shapeLen ) {
				shape = group[shapeNum];
				elemNum = -1;
				elemLen = shape.length;
				while ( ++elemNum < elemLen ) {
					elem = shape[elemNum];
					elem.apply(graphics, scale, offsetX, offsetY);
				}
			}
		}
		
		public function SWFShapeRecordSimple(data:SWFData, tagType:uint) {
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
			if ( _shapesGroup.length > 0 ) {
				calculateBounds();
			} else {
				_bounds = new Rectangle(0, 0, 0, 0);
			}
		}
		
		private var _tagType				:uint;
		private var _fillBits				:uint;
		private var _lineBits				:uint;
		private var _hasStyle				:Boolean;
		private var _hasAlpha				:Boolean;
		private var _hasExtendedFill		:Boolean;
		private var _hasStateNewStyle		:Boolean;
		private var _bounds					:Rectangle;
		private var _fillStyles				:Array;
		private var _lineStyles				:Array;

		private var _currentFillStyle		:SWFGraphicsElement;
		private var _currentLineStyle		:SWFGraphicsElement;
		private var _currentShape			:Array;
		private var _shapesGroup			:Array;
		
		private function parse(data:SWFData):void {
			var dx:Number = 0;
			var dy:Number = 0;
			var curve:SWFGraphicsCurve;
			var line:SWFGraphicsLine;
			var move:SWFGraphicsMove;
			
			_shapesGroup = new Array();
			_fillStyles = new Array();
			_lineStyles = new Array();
			_currentShape = new Array();
			
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
						addElement(curve = new SWFGraphicsCurve(data, dx, dy));
						dx = curve.x;
						dy = curve.y;
					} else {
						addElement(line = new SWFGraphicsLine(data, dx, dy));
						dx = line.x;
						dy = line.y;
					}
				} else {
					// Change Record or End
					var flags:uint = data.readUBits(5);
					if ( flags == 0 ) {
						// end
						break;
					}
					var stateMoveTo :Boolean = (flags & 0x01) != 0;
					if ( stateMoveTo ) {
						addElement(move = new SWFGraphicsMove(data));
						dx = move.x;
						dy = move.y;
					}
					parseChangeRecord(data, flags);
				}
			}
			closeShapeIfNewFill(true);
		}
		

		private function parseChangeRecord(data:SWFData, flags:uint):void {
			var stateFillStyle0	:Boolean = (flags & 0x02) != 0;
			var stateFillStyle1	:Boolean = (flags & 0x04) != 0;
			var stateLineStyle	:Boolean = (flags & 0x08) != 0;
			var stateNewStyles	:Boolean = (flags & 0x10) != 0;
			var fillStyle0		:int;
			var fillStyle1		:int;
			var lineStyle		:int;
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
				// we're ignoring two fill edges here which is the wrong way to parse the data
				// but works if there are no two fill edges in the shape. it also returns data
				// that is easier to work with
				_currentFillStyle = null;
				if ( fillStyle0 > 0 && _fillStyles[fillStyle0 - 1] ) {
					_currentFillStyle = _fillStyles[fillStyle0 - 1];
				}
				if ( fillStyle1 > 0 && _fillStyles[fillStyle1 - 1] ) {
					_currentFillStyle = _fillStyles[fillStyle1 - 1];
				}
				if ( lineStyle > 0 && _lineStyles[lineStyle - 1] ) {
					_currentLineStyle = _lineStyles[lineStyle - 1];
				} else {
					_currentLineStyle = new SWFGraphicsLineStyle();
				}
			}
			if ( _hasStateNewStyle && stateNewStyles ) {
				parseStyles(data);
				_fillBits = data.readUBits(4);
				_lineBits = data.readUBits(4);
			}
		}
		
		private function parseStyles(data:SWFData):void {
			_fillStyles = new Array();
			_lineStyles = new Array();
			
			var i:int;
			var numFillStyles:int = data.readUnsignedByte();
			if ( _hasExtendedFill && numFillStyles == 0xff ) {
				numFillStyles = data.readUnsignedShort();
			}
			for ( i = 0; i < numFillStyles; ++i ) {
				_fillStyles.push(new SWFGraphicsFillStyle(data, _hasAlpha));
			}
			
			var numLineStyles:int = data.readUnsignedByte();
			if ( numLineStyles == 0xff ) {
				numLineStyles = data.readUnsignedShort();
			}
			for ( i = 0; i < numLineStyles; ++i ) {
				if ( _tagType == SWFTagTypes.DEFINE_SHAPE4 ) {
					_lineStyles.push(new SWFGraphicsLineStyle2(data, _hasAlpha, _tagType));
				} else {
					_lineStyles.push(new SWFGraphicsLineStyle(data, _hasAlpha));
				}
			}
		}
		
		private function addElement(elem:SWFGraphicsElement):void {
			if ( elem.type == "M" ) {
				closeShapeIfNewFill();
			}
			_currentShape.push(elem);
		}
		
		private function closeShapeIfNewFill(forceClose:Boolean = false):void {
			if ( _currentShape.length > 0 ) {
				if ( forceClose || _currentFillStyle ) {
					if ( _currentFillStyle ) {
						_currentShape.unshift(_currentFillStyle);
					}
					if ( _currentLineStyle ) {
						_currentShape.unshift(_currentLineStyle);
					}
					_shapesGroup.push(_currentShape);
					_currentShape = new Array();
				} else {
					if ( _currentLineStyle ) {
						_currentShape.push(_currentLineStyle);
					}
				}
			}
		}
		
		private function calculateBounds():void {
			var g:Graphics = _shape.graphics;
			g.clear();
			g.beginFill(0);
			drawShape(g, this);
			g.endFill();
			_bounds = _shape.getRect(_shape);
		}
		
		public function get bounds():Rectangle { return _bounds; }
		public function get shapesGroup():Array { return _shapesGroup; }
		
	}
}