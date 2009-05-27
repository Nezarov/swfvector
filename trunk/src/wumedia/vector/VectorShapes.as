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
package wumedia.vector {
	import wumedia.parsers.swf.SWFData;
	import wumedia.parsers.swf.SWFMatrix;
	import wumedia.parsers.swf.SWFParser;
	import wumedia.parsers.swf.SWFRect;
	import wumedia.parsers.swf.SWFShapeRecord;
	import wumedia.parsers.swf.SWFShapeRecordSimple;
	import wumedia.parsers.swf.SWFTag;
	import wumedia.parsers.swf.SWFTagTypes;
	
	import flash.geom.Matrix;
	import flash.utils.ByteArray;
	import flash.utils.getQualifiedClassName;	
	/**
	 * @author guojian@wu-media.com
	 */
	public class VectorShapes {
		static public const METHOD_CONTINUOUS_POINTS	:uint = 0;
		static public const METHOD_REGULAR				:uint = 1;
		static private var _library						:Object = new Object();
		
		/**
		 * Draw a vector shape
		 * @param graphics	the target where to draw to
		 * @param id	The id of the vector to draw
		 * @param scale	Scale the shape, 1.0 = no scale
		 * @param offsetX	The x offset
		 * @param offsetY	The y offset
		 */
		static public function draw(graphics:*, id:String, scale:Number = 1.0, offsetX:Number = 0.0, offsetY:Number = 0.0):void {
			if ( !_library[id] ) {
				trace("ERROR: missing " + id + " vector");
			} else if ( _library[id] is SWFShapeRecordSimple ) {
				SWFShapeRecordSimple.drawShape(graphics, _library[id], scale, offsetX, offsetY);
			} else {
				SWFShapeRecord.drawShape(graphics, _library[id], scale, offsetX, offsetY);
			}
		}

		/**
		 * Extract vector shapes from the swf Sprite/MovieClip library.
		 * @param bytes	The ByteArray for the source (swf)
		 * @param ids	An Array of class names/linkage names where the shapes are contained
		 * @param method	The prefered method is METHOD_CONTINUOUS_POINTS although it does not
		 * 					support all vectors, it is friendlier to work with.  METHOD_REGULAR supports
		 * 					all vectors but the data is not friendly to 3D operations like extruding.
		 * 					
		 * 					Warning: METHOD_REGULAR causes slower rendering due to more drawing passes
		 * 					required.
		 * 					
		 * 					NOTE: To usse METHOD_CONTINUOUS_POINTS, your vector data must be on the same layer
		 * 					separated by groups. Vector data that is flat and overlapping will require
		 * 					METHOD_REGULAR to render properly.
		 */
		static public function extractFromLibrary( bytes:ByteArray, ids:Array, method:uint = METHOD_CONTINUOUS_POINTS ):void {
			try {
				var swf:SWFParser = new SWFParser(bytes);
				var classes:Object = parseClassIdTable(swf);
				var sprites:Array = swf.parseTags([
					SWFTagTypes.DEFINE_SPRITE
					], true).filter(function(tag:SWFTag, ...args):Boolean {
						var spriteId:uint = tag.data.readUnsignedShort();
						tag.data.position -= 2;
						return ids.indexOf(classes[spriteId]) != -1;
					});
				var i:int = -1;
				var l:int = sprites.length;
				while ( ++i < l ) {
					sprites[i].data.readUnsignedInt(); // move read position to tags
					var placeTags:Array = parsePlacetags(swf.parseTags([
						SWFTagTypes.PLACE_OBJECT,
						SWFTagTypes.PLACE_OBJECT2,
						SWFTagTypes.PLACE_OBJECT3
						], true, 1, sprites[i].data));
					var defineShape:SWFTag = getShapeFromPlaceTags(swf, placeTags);
					if ( defineShape ) {
						sprites[i].data.position = 0;
						var spriteId:uint = sprites[i].data.readUnsignedShort();
						defineShape.data.position = 0;
						shiftDataPosToShapeRecord(defineShape.data, defineShape.type);
						if ( _library[classes[spriteId]] ) {
							trace("WARNING: vector shape with id " + classes[spriteId] +  " already exists. replacing.");
						}
						if ( method == METHOD_REGULAR ) {
							_library[classes[spriteId]] = new SWFShapeRecord(defineShape.data, defineShape.type);	
						} else {
							_library[classes[spriteId]] = new SWFShapeRecordSimple(defineShape.data, defineShape.type);	
						}
					}
				}
			} catch (err:Error) {
				trace("**************************************************");
				trace("** Error: unable to extract vectors from swf bytes");
				trace(err.getStackTrace());
				trace("**************************************************");
			}
		}
		/**
		 * Extract vector shapes from 1st frame of the main timeline
		 * @param bytes	The ByteArray for the source (swf)
		 * @param id	The name you want to give this shape
		 * @param method	The prefered method is METHOD_CONTINUOUS_POINTS although it does not
		 * 					support all vectors, it is friendlier to work with.  METHOD_REGULAR supports
		 * 					all vectors but the data is not friendly to 3D operations like extruding.
		 * 					
		 * 					Warning: METHOD_REGULAR causes slower rendering due to more drawing passes
		 * 					required.
		 * 					
		 * 					NOTE: To usse METHOD_CONTINUOUS_POINTS, your vector data must be on the same layer
		 * 					separated by groups. Vector data that is flat and overlapping will require
		 * 					METHOD_REGULAR to render properly.
		 */
		static public function extractFromStage( bytes:ByteArray, id:String, method:uint = METHOD_CONTINUOUS_POINTS ):void {
			try {
				if ( _library[id] ) {
					throw new Error(id + " already exists");
				}
				var swf:SWFParser = new SWFParser(bytes);
				var placeTags:Array = parsePlacetags(swf.parseTags([
					SWFTagTypes.PLACE_OBJECT,
					SWFTagTypes.PLACE_OBJECT2,
					SWFTagTypes.PLACE_OBJECT3
					], true, 1));
				var defineShape:SWFTag = getShapeFromPlaceTags(swf, placeTags);
				if ( defineShape ) {
					defineShape.data.position = 0;
					shiftDataPosToShapeRecord(defineShape.data, defineShape.type);
					if ( _library[id] ) {
							trace("WARNING: vector shape with id " + id +  " already exists. replacing.");
						}
					if ( method == METHOD_REGULAR ) {
						_library[id] = new SWFShapeRecord(defineShape.data, defineShape.type);	
					} else {
						_library[id] = new SWFShapeRecordSimple(defineShape.data, defineShape.type);	
					}
				} else {
					throw new Error("no shapes found");
				}
			} catch (err:Error) {
				trace("**************************************************");
				trace("** Error: unable to extract vectors from swf bytes");
				trace(err.getStackTrace());
				trace("**************************************************");
			}
		}

		static private function getShapeFromPlaceTags(swf:SWFParser, placeTags:Array):SWFTag {
			var lib:Array = swf.parseTags([
				SWFTagTypes.DEFINE_SHAPE,
				SWFTagTypes.DEFINE_SHAPE2,
				SWFTagTypes.DEFINE_SHAPE3,
				SWFTagTypes.DEFINE_SHAPE4
				], true).filter(function(tag:SWFTag, ...args):Boolean {
					var shapeId:uint = tag.data.readUnsignedShort();
					tag.data.position = 0;
					return placeTags.indexOf(shapeId) != -1;
				});
			return lib[0];
		}
		
		static private function parsePlacetags( tags:Array ):Array {
			var result:Array = [];
			var i:int = -1;
			var l:int = tags.length;
			var shapeId:uint;
			var matrix:Matrix;
			var placeData:SWFData;
			var placeType:uint;
			var placeFlags:uint;
			while ( ++i < l ) {
				placeData = tags[i].data;
				placeType = tags[i].type;
				if ( placeType == SWFTagTypes.PLACE_OBJECT ) {
					shapeId = placeData.readUnsignedShort();
					placeData.readUnsignedShort(); // depth
					matrix = new SWFMatrix(placeData);
				} else if ( placeType == SWFTagTypes.PLACE_OBJECT2 ) {
					placeData.readUBits(8); // flags
					placeData.readUnsignedShort(); // depth
					shapeId = placeData.readUnsignedShort();
					matrix = new SWFMatrix(placeData);
				} else if ( placeType == SWFTagTypes.PLACE_OBJECT2 ) {
					placeFlags = placeData.readUBits(16); // tags
					if ( (placeFlags & 8 ) != 0
							|| (placeFlags & 16 ) != 0
							|| (placeFlags & 512 ) != 0 ) {
						placeData.readString(); // name of class for placed object
					}
					shapeId = placeData.readUnsignedShort();
					matrix = new SWFMatrix(placeData);
				} else {
					shapeId = 0;
				}
				if ( shapeId != 0 ) {
					result.push(shapeId);
					result.push(matrix);
				}
			}
			return result;
		}
		
		static private function parseClassIdTable( swf:SWFParser ):Object {
			var result:Object = {};
			var tags:Array = swf.parseTags(SWFTagTypes.SYMBOL_CLASS, true);
			if ( tags.length != 1 ) {
				// no symbol class found
				return result;
			}
			var tagData:SWFData = tags[0].data;
			var numSymbols:uint = tagData.readUnsignedShort();
			var i:int = -1;
			while ( ++i < numSymbols ) {
				var symbolId:uint = tagData.readUnsignedShort();
				var symbolName:String = tagData.readString();
				result[symbolId] = symbolName;
			}
			return result;
		}
		
		static private function shiftDataPosToShapeRecord(data:SWFData, defineShapeType:uint ):void {
			data.readUnsignedShort();
			new SWFRect(data);
			if ( defineShapeType == SWFTagTypes.DEFINE_SHAPE4 ) {
				new SWFRect(data); // bounds
				data.readUBits(5); // reversed - must be 0;
				data.readUBits(1); // UsesFillWindingRule if 1 (swf 10)
				data.readUBits(1); // UsesNonScalingStrokes
				data.readUBits(1); // UsesScalingStrokes
			}
		}

		public function VectorShapes() {
			throw new Error(getQualifiedClassName(this) + " can not be instantiated");
		}
	}
}
