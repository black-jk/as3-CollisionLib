package collision {
	import blackjk.controls.MessageWindow;
	import blackjk.math.LineSegment;
	import blackjk.math.Vector2;
	
	import flash.events.MouseEvent;
	
	import mx.core.UIComponent;
	
	// ----------------------------------------------------------------------------------------------------
	
	public class Partical extends UIComponent {
		
		// ----------------------------------------------------------------------------------------------------
		
		public static var collisionWallDecay:Number = 1;
		public static var collisionParticalDecay:Number = 1;
		
		// --------------------------------------------------
		
		
		// k q
		public static const K:Number = 0.5;
		public var q:Number = 10;
		
		// k q temp
		public const force:Vector2 = new Vector2;
		
		
		
		// ====================================================================================================
		
		public function Partical(radius:Number) {
			super();
			
			this.radius = radius;
			
			// debug
			addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		}
		
		
		
		// ----------------------------------------------------------------------------------------------------
		
		protected var _radius:Number = 10;
		
		public function get radius():Number {
			return _radius;
		}
		
		public function set radius(value:Number):void {
			_radius = value;
			
			_mass = _radius * _radius;
			
		}
		
		// ----------------------------------------------------------------------------------------------------
		
		protected var _mass:Number;
		
		public function get mass():Number {
			return _mass;
		}
		
		public function set mass(value:Number):void {
			_mass = value;
		}
		
		
		
		// ----------------------------------------------------------------------------------------------------
		
		public var particalColor:uint = 0x222222 + 0xCCCCCC * Math.random();
		
		// --------------------------------------------------
		
		public function render():void {
			x = position.x;
			y = position.y;
			
			graphics.clear();
			graphics.beginFill(particalColor, 1);
			graphics.drawCircle(0, 0, radius);
			
			graphics.lineStyle(0, 0xff0000);
			graphics.moveTo(0, 0);
			graphics.lineTo(speed.x, speed.y);
		}
		
		
		
		// ----------------------------------------------------------------------------------------------------
		// [Collision]
		// ----------------------------------------------------------------------------------------------------
		
		public const position:Vector2 = new Vector2;
		public const speed:Vector2 = new Vector2;
		
		
		// --------------------------------------------------
		
		// [Temp data]
		
		public var moveRate:Number = 1;
		
		
		public var moveRateTemp:Number;
		public var targetWall:LineSegment = null;
		public var targetPartical:Partical = null ;
		
		public var dataChanged:Boolean;
		
		public static function compareMoveRate(A:Partical, B:Partical):int {
			if (A.moveRateTemp < B.moveRateTemp)
				return -1;
			
			if (A.moveRateTemp > B.moveRateTemp)
				return  1;
			
			return 0;
		}
		
		
		
		// ----------------------------------------------------------------------------------------------------
		
		// [wall]
		
		// return: move rate
		public function collisionToWall(wall:LineSegment):Number {
			if (moveRate <= 0)
				return -1;
			
			var moveVec:Vector2 = speed.clone();
			//moveVec.scale(moveRate);
			
			var closedPoint:Vector2 = wall.closedPoint(position);
			var p2w:Vector2 = position.deltaV(closedPoint);
			var p2wLength:Number = p2w.length;
			
			// p2w 。 moveVec
			var dot:Number = p2w.dot(moveVec);
			if (dot <= 0)
				return -1;
			
			p2w.scale((dot / p2wLength) / p2wLength * moveRate);
			var headLength:Number = p2w.length + _radius;
			
			//MessageWindow.appendText(headLength +">="+ p2wLength);
			if (headLength >= p2wLength) {
				var a:Number = p2wLength - _radius;
				var b:Number = headLength - _radius;
				
				//MessageWindow.appendText(a + " :: " + b);
				
				return (a / b) * moveRate;  // fix bug 
			}
			
			return moveRate;
		}
		
		
		
		// move with collision to wall
		public function doCollisionWall(wall:LineSegment, moveRate:Number):void {
			if (moveRate < 0) {
				MessageWindow.appendText("[Error] doCollisionWall(): moveRate = " + moveRate);
				return;
			} else
			if (moveRate == 0) {
				doCollisionWallZero(wall);
				return;
			}
			
			var moveVec:Vector2 = speed.clone();
			moveVec.scale(moveRate);
			
			var closedPoint:Vector2 = wall.closedPoint(position);
			var w2p:Vector2 = closedPoint.deltaV(position);
			w2p.scale((w2p.dot(moveVec) / w2p.length / w2p.length));
			
			position.concat(moveVec);
			speed.concatValue(-2 * w2p.x / moveRate, -2 * w2p.y / moveRate);
			
			// collisionWallDecay
			speed.scale(collisionWallDecay);
			
			this.moveRate -= moveRate;
		}
		
		protected function doCollisionWallZero(wall:LineSegment):void {
			var closedPoint:Vector2 = wall.closedPoint(position);
			var w2p:Vector2 = closedPoint.deltaV(position);
			w2p.scale((w2p.dot(speed) / Math.pow(w2p.length, 2)));
			
			speed.concatValue(-2 * w2p.x, -2 * w2p.y);
			
			// collisionWallDecay
			speed.scale(collisionWallDecay);
		}
		
		// --------------------------------------------------------------------
		
		public function get moveRadius():Number {
			return _radius + speed.length * moveRate;
		}
		
		// --------------------------------------------------------------------
		
		public function collisionToPartical(partical:Partical):Number {
			if (moveRate <= 0)
				return -1;
			
			// too far
			var distance:Number = position.deltaV(partical.position).length;
			if (moveRadius + partical.moveRadius < distance)
				return -1;
			//MessageWindow.appendText("Trace -------- 1");
			
			/*/
			// speed direction to cross point
			var line1:Line = new Line(0, 0, position, speed);
			var line2:Line = new Line(0, 0, partical.position, partical.speed);
			var crossPoint:Vector2 = line1.cross(line2);
			if (crossPoint) {
				//MessageWindow.appendText("crossPoint: " + crossPoint.toString());
				var a2c:Vector2 = position.deltaV(crossPoint);
				if (a2c.dot(speed) <= 0) return -1;
				//MessageWindow.appendText("Trace -------- 2");
				
				var b2c:Vector2 = partical.position.deltaV(crossPoint);
				if (b2c.dot(partical.speed) <= 0) return -1;
				//MessageWindow.appendText("Trace -------- 3");
			}
			//*/
			
			var veloceA:Vector2 = speed.clone();  veloceA.scale(moveRate);
			var Px1:Number = position.x, Py1:Number = position.y;
			var Vx1:Number = veloceA.x,  Vy1:Number = veloceA.y;
			
			var veloceB:Vector2 = partical.speed.clone();  veloceB.scale(partical.moveRate);
			var Px2:Number = partical.position.x, Py2:Number = partical.position.y;
			var Vx2:Number = veloceB.x,           Vy2:Number = veloceB.y;
			
			return calcParticCollision(Px1, Py1, Vx1, Vy1, Px2, Py2, Vx2, Vy2, (radius + partical.radius));
		}
		
		// ----------------------------------------------------------------------------------------------------
		
		public function calcParticCollision(Px1:Number, Py1:Number, Vx1:Number, Vy1:Number,
											Px2:Number, Py2:Number, Vx2:Number, Vy2:Number, distance:Number):Number {
			
			var A:Number =    Vx1*Vx1 + Vx2*Vx2 + Vy1*Vy1 + Vy2*Vy2  - 2*(Vx1*Vx2 + Vy1*Vy2);
			var B:Number = 2*(Px1*Vx1 + Px2*Vx2 + Py1*Vy1 + Py2*Vy2) - 2*(Px1*Vx2 + Px2*Vx1 + Py1*Vy2 + Py2*Vy1);
			var C:Number =    Px1*Px1 + Px2*Px2 + Py1*Py1 + Py2*Py2  - 2*(Px1*Px2 + Py1*Py2) - Math.pow(distance, 2);
			
			var B2:Number = Math.pow(B, 2);
			var AC4:Number = 4 * A * C;
			if (B2 < AC4)
				return -1;
			
			var B2_4AC:Number = B2 - AC4;
			var B2_4AC_sqrt:Number = Math.sqrt(B2_4AC);
			
			//var t1:Number = (B2_4AC_sqrt - B) / (2 * A);  // not used
			var t2:Number = (-B2_4AC_sqrt - B) / (2 * A);
			if (t2 < 0 || t2 > 1)
				return -1;
			
			//MessageWindow.appendText(t1 + " : " + t2);
			//MessageWindow.appendText("- - - - - - - -");
			
			return moveRate * t2;
		}
		
		// ----------------------------------------------------------------------------------------------------
		
		// move with collision to partical
		public static function doCollisionPartical(particalA:Partical, moveRateA:Number,
												   particalB:Partical, moveRateB:Number):void {
			
			if (moveRateA < 0) {
				MessageWindow.appendText("[Error] doCollisionPartical(): moveRate = " + moveRateA);
				return;
			}/*
			else
			if (moveRateA == 0 || moveRateB == 0) {
				doCollisionParticalZero(particalA, particalB);
				return;
			}
			*/
			
			// move to collision point
			particalA.doMove(moveRateA);
			particalB.doMove(moveRateB);
			
			var deltaV:Vector2 = particalA.position.deltaV(particalB.position);  deltaV.normalize();
			var totalMass:Number = particalA.mass + particalB.mass;
			var moveVecA:Vector2 = particalA.speed;//  moveVecA.scale(moveRateA);
			var moveVecB:Vector2 = particalB.speed;//  moveVecB.scale(moveRateB);
			
			
			//分量大小
			var v1:Number = moveVecA.dot(deltaV);
			var v2:Number = moveVecB.dot(deltaV);
			
			//套用碰撞公式
			var newV1:Number = (particalA.mass - particalB.mass)/totalMass*v1 + (particalB.mass + particalB.mass)/totalMass*v2;
			var newV2:Number = (particalA.mass + particalA.mass)/totalMass*v1 + (particalB.mass - particalA.mass)/totalMass*v2;
			
			particalA.speed.x += (newV1-v1)*deltaV.x;
			particalA.speed.y += (newV1-v1)*deltaV.y;
			particalB.speed.x += (newV2-v2)*deltaV.x;
			particalB.speed.y += (newV2-v2)*deltaV.y;
			
			// collisionParticalDecay
			if (collisionParticalDecay != 1) {
				particalA.speed.scale(collisionParticalDecay);
				particalB.speed.scale(collisionParticalDecay);
			}
		}
		
		// --------------------------------------------------
		
		/*
		protected static function doCollisionParticalZero(particalA:Partical, particalB:Partical):void {
			MessageWindow.appendText("doCollisionParticalZero(particalA, particalB);");
		}
		*/
		
		
		
		// ----------------------------------------------------------------------------------------------------
		
		// move with collision to fixed partical
		//public function doCollisionFixedPartical(partical:Partical):void {}
		
		// ----------------------------------------------------------------------------------------------------
		
		// move without collision
		public function doMove(moveRate:Number=NaN):void {  // -n to fix collision over
			if (isNaN(moveRate))
				moveRate = this.moveRate;
			
			var moveVec:Vector2 = speed.clone();
			moveVec.scale(moveRate);
			position.concat(moveVec);
			
			this.moveRate -= moveRate;
		}
		
		
		
		
		// ----------------------------------------------------------------------------------------------------
		
		// [debug]
		override public function toString():String {
			return "[Partical] " + name + "\np:" + position.toString() + ",  v:" + speed.toString() + ", remain:" + moveRate; 
		}
		
		// ----------------------------------------------------------------------------------------------------
		
		private function onMouseDown(evt:MouseEvent):void {
			MessageWindow.appendText(this.toString());
		}
		
		// ----------------------------------------------------------------------------------------------------
		
	}
}
