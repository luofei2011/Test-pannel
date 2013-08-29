package
{
	import flash.display.Sprite;
	import flash.display.StageScaleMode;
	
	public class TestPannel extends Sprite
	{
		private var _graphicContainer:Sprite;
		private var _test:Array = [1, 1000, 45, 800, 56, 222, 56, 21, 94, 12, 34, 52, 16, 832, 21, 5];
		
		public function TestPannel()
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			drawXpos();
		}
		
		private function drawXpos():void {
			var _row:int = calcGraphicRow(_test);
			var _rows:int = Math.floor(160 / _row);
			var _histogram:Sprite = new Sprite();
			var _dYpos:int = 160 - _rows * _row;
			
			for (var i:uint = 0; i < _row; i++) {
				var _signal1:Sprite = drawSignalLine((_rows - 1) / 2);
				var _signal2:Sprite = drawSignalLine((_rows - 1) / 2);
				
				_signal1.y = (_rows - 1) * i;
				_signal2.y = _signal1.y + (_rows - 1) / 2;
				
				_histogram.addChild(_signal1);
				_histogram.addChild(_signal2);
				
				drawLine(_signal1.y);
				
				if (i == _row - 1) 
					drawLine(_signal2.y + _signal2.height);
			}
//			_histogram.graphics.clear();
//			_histogram.graphics.beginFill(0x57CCDD);
//			_histogram.graphics.drawRect(0, 0, 8, 160);
//			_histogram.graphics.endFill();
			addChild(_histogram);
			trace("+++++++++++", _histogram.height)
		}
		
		private function drawLine(y:int):void {
			var _line:Sprite = new Sprite();
			_line.graphics.clear();
			_line.graphics.lineStyle(1, 0xEEEEEE);
			_line.graphics.moveTo(8, y);
			_line.graphics.lineTo(8 + 515, y);
			_line.graphics.endFill();
			
			addChild(_line);
		}
		
		private function drawSignalLine(h:int):Sprite {
			var _con:Sprite = new Sprite();
			_con.graphics.clear();
			_con.graphics.beginFill(0x57CCDD);
			_con.graphics.drawRect(0, 0, 8, h);
			_con.graphics.endFill();
			
			return _con;
		}
		
		private function average(arr:Array):Number {
			var _sum:Number = 0;
			for (var i:uint = 0; i < arr.length; i++) {
				_sum += arr[i];
			}
			return _sum / arr.length;
		}
		
		private function calcGraphicRow(arr:Array):int {
			var _p:Number = average(arr);
			var _tmp:Number = 0;
			var _value:Number = 0;
			for (var i:uint = 0; i < arr.length; i++) {
				_tmp += Math.pow(_p - arr[i], 2);
			}
			_value =  (Math.sqrt(_tmp / arr.length) / _p);
			
			if (_value <= 0.2)
				return 4;
			else if (_value > 0.2 && _value <= 0.4)
				return 5;
			else if (_value > 0.4 && _value <= 0.6)
				return 6;
			else if (_value > 0.6 && _value <= 0.8)
				return 7;
			else if (_value > 0.8)
				return 8;
			else 
				return 4;
		}
	}
}


