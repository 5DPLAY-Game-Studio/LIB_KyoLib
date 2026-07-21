/*
 * Copyright (C) 2021-2024, 5DPLAY Game Studio
 * All rights reserved.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

package net.play5d.kyo.utils {
import flash.events.TimerEvent;
import flash.utils.Timer;

/**
 * 时钟：维护当前 <code>Date</code>、格式化时间，并按间隔回调。
 *
 * <p>时间格式化可配合 <code>KyoTimerFormat</code>。</p>
 *
 * @see #start()
 * @see #now
 * @see KyoTimerFormat
 * @author kyo
 */
public class KyoClock {
    /**
     * 构造函数。
     */
    public function KyoClock() {
    }

    /**
     * 当前时间；由定时器刷新。
     */
    public var now:Date = new Date();
    /** @private */
    private var _timer:Timer;
    /** @private */
    private var _functions:Array = [];

    /**
     * 是否为上午（小时 &lt; 12）。
     */
    public function get isam():Boolean {
        return now.hours < 12;
    }

    /**
     * 时分字符串（如 <code>xx:xx</code>）。
     */
    public function get time():String {
        return KyoTimerFormat.getTime(now, ':', false);
    }

    /**
     * 时分秒字符串（如 <code>xx:xx:xx</code>）。
     */
    public function get time2():String {
        return KyoTimerFormat.getTime(now, ':', true);
    }

    /**
     * 日期字符串 <code>年.月.日</code>。
     */
    public function get date():String {
        return now.fullYear + '.' + (now.month + 1) + '.' + now.date;
    }

    /**
     * 星期文案。
     */
    public function get day():String {
        return KyoTimerFormat.getDay(now, 2);
    }

    /**
     * 自定义时间字符串。
     * @param type24 是否 24 小时制。
     * @param srcond 是否含秒（历史拼写）。
     * @param ampm 是否追加 am/pm。
     * @return 时间字符串。
     * @example
     * <listing version="3.0">
     * clock.getTime(true, true);
     * </listing>
     */
    public function getTime(type24:Boolean = true, srcond:Boolean = false, ampm:Boolean = false):String {
        var sr:String = KyoTimerFormat.getTime(now, ':', srcond, type24);
        if (ampm) {
            var apm:String = now.hours < 12 ? 'am' : 'pm';
            sr += ' ' + apm;
        }
        return sr;
    }

    /**
     * 带中文单位的日期字符串。
     * @param ys 年后缀。
     * @param ms 月后缀。
     * @param ds 日后缀。
     * @return 日期字符串。
     * @example
     * <listing version="3.0">
     * clock.getDateStr();
     * </listing>
     */
    public function getDateStr(ys:String = '年', ms:String = '月', ds:String = '日'):String {
        return now.fullYear + ys + KyoTimerFormat.formatNum(now.month + 1) + ms + KyoTimerFormat.formatNum(now.date) +
               ds;
    }

    /**
     * 注册定时回调。
     * @param fun 回调函数。
     * @param params 传给 <code>apply</code> 的参数数组；可省略。
     * @example
     * <listing version="3.0">
     * clock.addCallBack(onTick);
     * </listing>
     */
    public function addCallBack(fun:Function, params:Array = null):void {
        var i:int = _functions.indexOf(fun);
        if (i == -1) {
            _functions.push([fun, params]);
        }
    }

    /**
     * 移除定时回调。
     * @param fun 曾注册的回调。
     * @example
     * <listing version="3.0">
     * clock.removeCallBack(onTick);
     * </listing>
     */
    public function removeCallBack(fun:Function):void {
        var i:int = _functions.indexOf(fun);
        if (i == -1) {
            _functions.splice(i, 1);
        }
    }

    /**
     * 启动定时刷新。
     * @param delay 间隔秒数。
     * @example
     * <listing version="3.0">
     * clock.start(1);
     * </listing>
     */
    public function start(delay:Number = 1):void {
        delay *= 1000;
        if (!_timer) {
            _timer = new Timer(delay);
            _timer.addEventListener(TimerEvent.TIMER, onTimer);
        }
        _timer.delay = delay;
        _timer.reset();
        _timer.start();
    }

    /**
     * 停止定时器。
     * @example
     * <listing version="3.0">
     * clock.stop();
     * </listing>
     */
    public function stop():void {
        if (_timer) {
            _timer.stop();
        }
    }

    /**
     * 复位定时器计数。
     * @example
     * <listing version="3.0">
     * clock.reset();
     * </listing>
     */
    public function reset():void {
        if (_timer) {
            _timer.reset();
        }
    }

    /**
     * 停止并释放定时器与回调表。
     * @example
     * <listing version="3.0">
     * clock.clear();
     * </listing>
     */
    public function clear():void {
        stop();
        if (_timer) {
            _timer.removeEventListener(TimerEvent.TIMER, onTimer);
            _timer = null;
        }
        _functions = null;
    }

    /**
     * @private
     */
    private function onTimer(e:TimerEvent):void {
        now = new Date();
        for each(var i:Array in _functions) {
            var f:Function = i[0];
            var p:Array    = i[1];
            f.apply(null, p);
        }
    }
}
}
