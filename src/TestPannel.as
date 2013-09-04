package
{
	import flash.display.Sprite;
	import flash.display.StageScaleMode;
	import flash.events.TimerEvent;
	import flash.text.TextField;
	import flash.utils.Timer;
	
	public class TestPannel extends Sprite
	{
		private var _colorArr:Array = [0xA5BC4E, 0xE48701, 0x074f85, 0x1ab20a, 0xe9f707];
		private var _data:Array = [];
		private var _prevNum:int = 1; // 前一次显示的最优解
		
		// 控制常量
		private var _container_width:int = 515;
		private var _container_height:int = 160;
		private var _max_show_num:int = 11;
		
		public function TestPannel()
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			for (var i:uint = 0; i < 5; i++) {
				_data[i] = [];
			}
			
			var _timer:Timer = new Timer(3000);
			_timer.addEventListener(TimerEvent.TIMER, function():void {
				for (var i:uint = 0; i < 5; i++) {
					_data[i].push({
						delay: Math.random() * 1500,
						date: new Date()
					});
				}
//				trace(_data[0][0].delay, _data[1][0].delay,_data[2][0].delay,_data[3][0].delay,_data[4][0].delay);
				init();
			});
			_timer.start();
		}
		
		private function init():void {
			removeChildren();
			// 处理源数据，得到最小值、最大值、以及平均值
			var msg:Object = dealArray(_data);
			
			// 画Y坐标轴
			drawYCoord();
			// 画标尺
			drawRuler(msg);
			// 画X坐标轴
			drawXCoord(msg);
			// 画结果曲线
			drawCvsLines(msg);
		}
		
		private function drawRuler(msg:Object):void {
			// 处理源数据，计算相对标准差并返回合适的数据分组
			var lines:int = getLines(msg);
			// 得到分组坐标值间隔
			var space:Number = _container_height / lines;
			// 得到数据源的极差
			var rang:Number = msg.max - msg.min;
			
			for (var i:uint = 0; i < lines + 1; i++) {
				var _l:Sprite = new Sprite();
				var _m:Sprite = new Sprite();
				var _txt:TextField = new TextField();
				var _label:int;
				_l.graphics.clear();
				_l.graphics.lineStyle(1, 0xEEEEEE);
				_l.graphics.moveTo(-8, i * space);
				_l.graphics.lineTo(_container_width, i * space);
				_l.graphics.endFill();
				
				_label =  msg.min + (lines - i) * (rang / lines);
				
				_txt.text = _label + "";
				_txt.x = -_txt.textWidth - 10;
				_txt.y = i * space - _txt.textHeight / 2 - 2;
				
				// 分割白线
				if (i) {
					_m.graphics.clear();
					_m.graphics.lineStyle(1, 0xFFFFFF);
					_m.graphics.moveTo(0, (i - 0.5) * space);
					_m.graphics.lineTo(8, (i - 0.5) * space);
					_m.graphics.endFill();
					
					addChild(_m);
				}
				
				addChild(_txt);
				addChild(_l);
			}
		}
		
		private function drawYCoord():void {
			var _container:Sprite = new Sprite();
			_container.graphics.clear();
			_container.graphics.beginFill(0x57CCDD);
			_container.graphics.drawRect(0, 0, 8, _container_height);
			_container.graphics.endFill();
			
			addChild(_container);
		}
		
		private function getPropertyGroup(d:uint):uint {
			while ((d / _prevNum) > _max_show_num) {
				_prevNum += 1;
			}
			return d / _prevNum;
		}
		
		private function drawXCoord(obj:Object):void {
			var _len:int = getPropertyGroup(obj.dltTime);
			var _startHours:int = parseInt(obj.srcData[0].date.getHours() + "");
			var _startMinutes:int = parseInt(obj.srcData[0].date.getMinutes() + "");
			var _startSeconds:int = parseInt(obj.srcData[0].date.getSeconds() + "");
			var _diff:Number = _container_width / _len;
			
			for (var i:uint = 0; i < _len; i++) {
				var _con:Sprite = new Sprite();
				var _txt:TextField = new TextField();
				var _x:int = 13 + _diff * i;
				var _time:String;
				_con.graphics.clear();
				_con.graphics.lineStyle(1, 0xBBCCDD);
				_con.graphics.moveTo(_x, _container_height);
				_con.graphics.lineTo(_x, _container_height + 8);
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
				_txt.y = _container_height + 8;
				_txt.x = _x - _txt.textWidth / 2 - 1;
				addChild(_txt);
			}
		}
			
		private function drawCvsLines(obj:Object):void {
			var _tmp:Array = [];
			var _len:int = _data.length;
			var _idx:uint = 0;
			var _xpos:Number;
			var _ypos:Number;
			
			for (; _idx < _len; _idx++) {
				_tmp = _data[_idx];
				var _l:Sprite = new Sprite();
				
				for (var i:uint = 0; i < _tmp.length; i++) {
					_xpos = (_container_width - 13) * (_tmp[i].date.time - _data[0][0].date.time) / (obj.dltTime * 1000) + 13;
					_ypos = calcTruelyY(obj, _tmp[i].delay);
					if (!i) {
						_l.graphics.clear();
						_l.graphics.lineStyle(1, _colorArr[_idx]);
						_l.graphics.moveTo(_xpos, _ypos);
					} else {
						_l.graphics.lineTo(_xpos, _ypos);
					}
				}
				_l.graphics.endFill();
				addChild(_l);
			}
		}
		
		private function calcTruelyY(obj:Object, y:Number):Number {
			return _container_height  - _container_height * (y - obj.min) / (obj.max - obj.min);
		}
		
		private function dealArray(arr:Array):Object {
			var _len:int;
			var _idx:uint = 0;
			var _tmp:Array = [];
			
			// 把N维数组拼接成一个数组
			for (var i:uint = 0; i < arr.length; i++) {
				if (arr[i].length) {
					_tmp = _tmp.concat(arr[i]);
				}
			}
			_len = _tmp.length;
			
			// 数组相关信息
			var _max:Number = _tmp[0].delay;
			var _min:Number = _tmp[0].delay;
			var _sum:Number = 0;
			
			// 数组信息的时间信息
			var _max_time:int = _tmp[0].date.time;
			var _min_time:int = _tmp[0].date.time;
			
			for (; _idx < _len; _idx++) {
				var _t:Object = _tmp[_idx];
				_sum += _tmp[_idx].delay;
				
				if (_t.delay > _max) {
					_max = _t.delay;
				}
				if (_t.delay < _min) {
					_min = _t.delay;
				}
				if (_t.date.time > _max_time)
					_max_time = _t.date.time;
				if (_t.date.time < _min_time)
					_min_time = _t.date.time;
			}
			
			// 返回的时候把最大值增加10%，最小值减少10%
			return {
				minTime: _min_time,
				dltTime: (_max_time - _min_time) / 1000, // 得到相隔的秒数
				srcData: _tmp,
				min: _min * 0.8,
				max: _max * 1.1,
				avg: _sum / _len
			};
		}
		
		private function getLines(obj:Object):int {
			// 存储标准差
			var _tmp:Number = 0;
			// 计算得到的相对标准差
			var _value:Number = 0;
			// 拼接过后的数组
			var _arr:Array = obj.srcData;
			var _len:int = _arr.length;
			
			for (var i:uint = 0; i < _len; i++) {
				_tmp += Math.pow(obj.avg - _arr[i].delay, 2);
			}
			_value =  (Math.sqrt(_tmp / _len) / obj.avg);
			
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
