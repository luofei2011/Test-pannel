package
{
	import flash.display.Sprite;
	import flash.display.StageScaleMode;
	import flash.events.TimerEvent;
	import flash.text.TextField;
	import flash.utils.Timer;
	
	public class TestPannel extends Sprite
	{
		private var _graphicContainer:Sprite;
		private var _test:Array = [1, 1000, 45, 800, 56, 222, 56, 21, 94, 12, 34, 52, 16, 832, 21, 5];
		private var _max_y:Number; // 纵轴极差
		private var _min:Number; // 记录当前组数据最小值
		private var _line:Sprite;
		private var _bottom:int; // 当前的底部坐标
		
		public function TestPannel()
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			_line = new Sprite();
			_graphicContainer = new Sprite();
			
			var _timer:Timer = new Timer(3000);
			_timer.addEventListener(TimerEvent.TIMER, function():void {
				_test = [];
				var _len:int = Math.random() * 30;
				if (_len > 16)
					_len = 16;
				for (var i:uint = 0; i < _len; i++) {
					_test.push(Math.random() * 1000);
				}
				flushDisplay();
			});
			_timer.start();
		}
		
		private function flushDisplay():void {
			removeChildren();
			drawYpos();
			drawXpos(_test);
		}
		
		private function drawYpos():void {
			var _row:int = calcGraphicRow(_test);
			var _rows:int = Math.floor(160 / _row);
			var _dYpos:int = 160 - _rows * _row;
			var _labelName:int;
			_graphicContainer.removeChildren();
			
			for (var i:uint = 0; i < _row; i++) {
				var _signal1:Sprite = drawSignalLine((_rows - 1) / 2);
				var _signal2:Sprite = drawSignalLine((_rows - 1) / 2);
				_labelName = _min + (_row - i) * (_max_y / _row);
				
				_signal1.y = (_rows - 1) * i;
				_signal2.y = _signal1.y + (_rows - 1) / 2;
				
				_graphicContainer.addChild(_signal1);
				_graphicContainer.addChild(_signal2);
				
				drawLine(_signal1.y, _labelName);
				
				if (i == _row - 1) {
					_bottom = _signal2.y + _signal2.height;
					drawLine(_bottom, _min);
				}
					
			}
			addChild(_graphicContainer);
		}
		
		private function drawXpos(arr:Array):void {
			var _num:int = arr.length;
			var _diff:int = 500 / _num;
			
			for (var i:uint = 0; i < _num; i++) {
				var _con:Sprite = new Sprite();
				var _txt:TextField = new TextField();
				var _x:int = 13 + _diff * i;
				_con.graphics.clear();
				_con.graphics.lineStyle(1, 0xBBCCDD);
				_con.graphics.moveTo(_x, _bottom);
				_con.graphics.lineTo(_x, _bottom + 8);
				_con.graphics.endFill();
				addChild(_con);
				
				_txt.text = i + "";
				_txt.y = _bottom + 8;
				_txt.x = _x - _txt.textWidth / 2 - 1;
				addChild(_txt);
				
				// 描点
				if (!i) {
					_line.graphics.clear();
					_line.graphics.lineStyle(3, 0xA5BC4E);
					_line.graphics.moveTo(_x, calcTruelyY(arr[i]));
				}
				_line.graphics.lineTo(_x, calcTruelyY(arr[i]));
			}
			_line.graphics.endFill();
			
			addChild(_line);
		}
		
		private function drawCurvedLine():void {
		
		}
		
		private function calcTruelyY(y:Number):Number {
			return _graphicContainer.height * (y - _min) / _max_y;
		}
		
		private function drawLine(y:int, value:int):void {
			var _xline:Sprite = new Sprite();
			var _label:Sprite = new Sprite();
			var _txt:TextField = new TextField();
			_xline.graphics.clear();
			_xline.graphics.lineStyle(1, 0xEEEEEE);
			_xline.graphics.moveTo(8, y);
			_xline.graphics.lineTo(8 + 515, y);
			_xline.graphics.endFill();
			
			_label.graphics.clear();
			_label.graphics.lineStyle(1, 0xEEEEEE);
			_label.graphics.moveTo(0, y);
			_label.graphics.lineTo(-8, y);
			_label.graphics.endFill();
			
			_txt.text = value + "";
			_txt.x = -_txt.textWidth - 10;
			_txt.y = y - _txt.textHeight / 2;
			
			addChild(_txt);
			addChild(_label);
			addChild(_xline);
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
			var _max:Number = 0;
			_min = 0;
			for (var i:uint = 0; i < arr.length; i++) {
				_sum += arr[i];
				
				if (arr[i] > _max)
					_max = arr[i];
				if (arr[i] < _min)
					_min = arr[i];
			}
			trace("max:", _max, _min)
			_max_y = _max - _min;
			
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