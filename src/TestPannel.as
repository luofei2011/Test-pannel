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
		private var _test:Array = [];
		private var _max_y:Number; // 数据极差
		private var _min:Number; // 数据最小值
		private var _avg:int; // 数据平均值
		private var _line:Sprite;
		private var _bottom:int; // 图标底线坐标
		private var _prevNum:int = 1; // x轴分组间隔, 单位(s)
		
		private var _max_show_num:int = 11; // x轴最大的显示数据项
		
		public function TestPannel()
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			_line = new Sprite();
			_graphicContainer = new Sprite();
			
			var _timer:Timer = new Timer(3000);
			_timer.addEventListener(TimerEvent.TIMER, function():void {
//				_test = [];
//				var _len:int = Math.random() * 300; 
//				for (var i:uint = 0; i < _len; i++) {
				_test.push({
					delay: Math.random() * 1500,
					date: new Date()
				}); 
//				}
				flushDisplay();
			});
			_timer.start();
		}
		
		private function flushDisplay():void {
			removeChildren();
			drawYpos();
			drawXpos();
		}
		
		private function drawYpos():void {
			var _row:int = calcGraphicRow(_test);
			var _rows:int = Math.floor(160 / _row);
			var _dYpos:int = 160 - _rows * _row; // 修正误差
			var _labelName:int;
			_graphicContainer.removeChildren();
			
			for (var i:uint = 0; i < _row; i++) {
				var _signal1:Sprite = drawSignalLine((_rows - 1) / 2);
				var _signal2:Sprite = drawSignalLine((_rows - 1) / 2);
				_labelName = _min + (_row - i) * (_max_y / _row);
				
				_signal1.y = _dYpos + (_rows - 1) * i;
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
		
        /*
         * 根据当前的事件间隔，递归找到合适的显示数据的分组
         * */
		private function getPropertyGroup(d:uint):uint {
			while ((d / _prevNum) > _max_show_num) {
				_prevNum += 1;
			}
			return d / _prevNum;
		}
		
		private function drawXpos():void {
			var arr:Array = _test;
			var _long:int = 500;
			if (!arr.length)
				return;
			var _num:int = _test.length;
			
			if (_num > 200) {
				arr = _test.slice(_test.length - 200);
				_num = arr.length;
			}
			
            // 当前组数据的时间间隔
			var _dTime:uint = (arr[_num - 1].date.time - arr[0].date.time) / 1000;
			var _len:uint = getPropertyGroup(_dTime) + 1;
			var _diff:int = _long / (_len - 1);
			
			var _startHours:int = parseInt(arr[0].date.getHours() + "");
			var _startMinutes:int = parseInt(arr[0].date.getMinutes() + "");
			var _startSeconds:int = parseInt(arr[0].date.getSeconds() + "");
			
			for (var i:uint = 0; i < _len; i++) {
				var _con:Sprite = new Sprite();
				var _txt:TextField = new TextField();
				var _x:int = 13 + _diff * i;
				var _time:String;
				_con.graphics.clear();
				_con.graphics.lineStyle(1, 0xBBCCDD);
				_con.graphics.moveTo(_x, _bottom);
				_con.graphics.lineTo(_x, _bottom + 8);
				_con.graphics.endFill();
				addChild(_con);
				
				_startSeconds += _prevNum;
				if (_startSeconds > 59) {
					_startSeconds -= 60;
					_startMinutes += 1;
					
					if (_startMinutes > 59) {
						_startMinutes -= 60;
						_startHours += 1;
					}
				}
				
				_time = (_startHours < 10) ? "0" + _startHours : _startHours + "";
				_time += ":";
				_time += (_startMinutes < 10) ? "0" + _startMinutes : _startMinutes;
				if (_prevNum < 59) {
					_time += ":";
					_time += (_startSeconds < 10) ? "0" + _startSeconds : _startSeconds;
				}
				
				_txt.text = _time;
				_txt.y = _bottom + 8;
				_txt.x = _x - _txt.textWidth / 2 - 1;
				addChild(_txt);
			}
			
			for (i = 0; i < _num; i++) {
				var _xpos:int = 500 * (arr[i].date.time - arr[0].date.time) / (_dTime * 1000) + 13;

				if (!i) {
					_line.graphics.clear();
					_line.graphics.lineStyle(1, 0xA5BC4E);
					_line.graphics.moveTo(_xpos, calcTruelyY(arr[i].delay));
				}
				_line.graphics.lineTo(_xpos, calcTruelyY(arr[i].delay));
				_line.graphics.endFill();
			}
			addChild(_line);
		}
		
        /*
         * @method 返回数据点在折线图中的真实Y轴坐标
         * @param {Number} y 数据源的真实值
         * @return {Number} 得到计算后的实际坐标
         * */
		private function calcTruelyY(y:Number):Number {
			return _graphicContainer.height  - _graphicContainer.height * (y - _min) / _max_y;
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
		
        /*
         * @method 计算数据内信息的平均值，最大值，最小值，极差等
         * @param {arr} arr 数据源
         * @return {Number} 返回平均值
         * */
		private function average(arr:Array):Number {
			var _sum:Number = 0;
			var _max:Number = 0;
			_min = 0;
			for (var i:uint = 0; i < arr.length; i++) {
				_sum += arr[i].delay;
				
				if (arr[i].delay > _max)
					_max = arr[i].delay;
				if (arr[i].delay < _min)
					_min = arr[i].delay;
			}
			_max_y = _max - _min;
			_avg = _sum / arr.length;
			
			return _avg;
		}
		
        /*
         * @method 计算当前组数据的相对标准差
         * @param {Array} arr 数据源
         * @return {int} 根据当前组数据的相对标准差来决定图标的纵坐标分组
         *
         * 注：根据一组数据的相对标准差动态决定数据的纵向分组,
         *     这里根据差值的0-1决定分组的4-8
         * */
		private function calcGraphicRow(arr:Array):int {
			var _p:Number = average(arr);
			var _tmp:Number = 0;
			var _value:Number = 0;
			for (var i:uint = 0; i < arr.length; i++) {
				_tmp += Math.pow(_p - arr[i].delay, 2);
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


