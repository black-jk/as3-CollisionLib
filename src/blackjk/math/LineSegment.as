package blackjk.math {
	
	// ----------------------------------------------------------------------------------------------------
	
	public class LineSegment extends Line {
		
		// ----------------------------------------------------------------------------------------------------
		
		public function LineSegment(vertexA:Vector2, vertexB:Vector2) {
			_vertexA = vertexA;
			_vertexB = vertexB;
			_A2BVec = _vertexA.deltaV(_vertexB);
			super(0, 0, _vertexA, _A2BVec);
		}
		
		
		
		// ----------------------------------------------------------------------------------------------------
		// [Vertex]
		// ----------------------------------------------------------------------------------------------------
		
		protected var _vertexA:Vector2;
		
		public function vertexA():Vector2 {
			return _vertexA;
		}
		
		// --------------------------------------------------
		
		protected var _vertexB:Vector2;
		
		public function vertexB():Vector2 {
			return _vertexB;
		}
		
		// --------------------------------------------------
		
		// [TODO] update when vertexA, vertexB changed
		protected var _A2BVec:Vector2;
		
		public function get length():Number {
			return _A2BVec.length;
		}
		
		
		
		// ----------------------------------------------------------------------------------------------------
		
		public function closedPoint(point:Point2):Vector2 {
			var perpLine:Line = perpendicularLine(point);
			var result:Vector2 = cross(perpLine);
			
			var p2A:Vector2 = _vertexA.deltaV(result);
			var p2B:Vector2 = _vertexB.deltaV(result);
			
			/*/
			if (p2A.length > length || p2B.length > length) {
				return null;
			}
			/*/
			if (p2A.length > length) {
				return _vertexB.clone();
			} else
			if (p2B.length > length) {
				return _vertexA.clone();
			}
			//*/
			
			return result; 
		}
		
		
		
		// ----------------------------------------------------------------------------------------------------
		
	}
}
