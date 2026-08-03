/*
 * Copyright (C) 2021-2026, 5DPLAY Game Studio
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
import flash.events.Event;

/**
 * 基于 <code>Timer</code> 的延时调用：返回 id、可清除，并支持全体暂停/恢复。
 *
 * <p>与帧驱动的 <code>KyoTimeout</code> 互补；适合应用暂停时需冻结的延时（如广告 SDK）。</p>
 *
 * @see #setTimeout()
 * @see #clearTimeout()
 * @see #pauseAllTimer()
 * @see KyoTimeout
 */
public class KyoTimerUtils {
    /** @private */
    private static var _timers:Object = {};

    /**
     * 延时调用。
     * @param func 回调。
     * @param delay 毫秒。
     * @param params 传给回调的参数。
     * @return 定时器 id，用于 <code>clearTimeout</code>。
     * @example
     * <listing version="3.0">
     * var id:int = KyoTimerUtils.setTimeout(onDone, 1000, arg);
     * </listing>
     */
    public static function setTimeout(func:Function, delay:int, ...params):int {
        var timer:KyoInsTimer = new KyoInsTimer(delay, func, params);
        timer.addEventListener(Event.COMPLETE, timerCompleteHandler);
        _timers[timer.id] = timer;
        return timer.id;
    }

    /**
     * 取消延时。
     * @param id <code>setTimeout</code> 返回值。
     */
    public static function clearTimeout(id:int):void {
        var timer:KyoInsTimer = _timers[id];
        if (timer) {
            timer.removeEventListener(Event.COMPLETE, timerCompleteHandler);
            timer.clear();
        }
        delete _timers[id];
    }

    /**
     * 暂停全部未完成定时器。
     */
    public static function pauseAllTimer():void {
        for (var i:String in _timers) {
            var t:KyoInsTimer = _timers[i];
            t.pause();
        }
    }

    /**
     * 恢复全部定时器。
     */
    public static function resumeAllTimer():void {
        for (var i:String in _timers) {
            var t:KyoInsTimer = _timers[i];
            t.resume();
        }
    }

    /** @private */
    private static function timerCompleteHandler(e:Event):void {
        var timer:KyoInsTimer = e.currentTarget as KyoInsTimer;
        clearTimeout(timer.id);
    }

}
}

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.TimerEvent;
import flash.utils.Timer;

/**
 * @private
 */
internal class KyoInsTimer extends EventDispatcher {
    public function KyoInsTimer(delay:Number, func:Function, params:Array) {
        this.id = (Math.random() * 100000) << 0;
        _func   = func;
        _params = params;
        _timer  = new Timer(delay, 1);
        _timer.addEventListener(TimerEvent.TIMER_COMPLETE, timerHandler);
        _timer.start();
    }
    public var id:int;
    private var _func:Function;
    private var _timer:Timer;
    private var _params:Array;

    public function pause():void {
        if (_timer) {
            _timer.stop();
        }
    }

    public function resume():void {
        if (_timer) {
            _timer.start();
        }
    }

    public function clear():void {
        if (_timer) {
            _timer.stop();
            _timer.removeEventListener(TimerEvent.TIMER_COMPLETE, timerHandler);
            _timer = null;
        }
        _func   = null;
        _params = null;
    }

    private function timerHandler(e:TimerEvent):void {
        if (_func != null) {
            if (_params) {
                _func.apply(null, _params);
            }
            else {
                _func();
            }
            _func   = null;
            _params = null;
        }
        dispatchEvent(new Event(Event.COMPLETE));
    }

}
