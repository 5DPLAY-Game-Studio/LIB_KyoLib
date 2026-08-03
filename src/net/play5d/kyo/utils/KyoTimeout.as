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
import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.events.Event;

/**
 * 基于 ENTER_FRAME 的延时调用（帧数或毫秒转帧）。
 *
 * <p><b>首选</b>游戏内节奏延时。使用前须 <code>init</code>。广告/应用暂停需冻结的延时用 <code>KyoTimerUtils</code>，勿与本类合并。</p>
 *
 * @see #init()
 * @see #setFrameout()
 * @see #setTimeout()
 * @see KyoTimerUtils
 */
public class KyoTimeout {
    /**
     * 已绑定的根显示对象（由 <code>init</code> 设置）。
     */
    public static var _root:DisplayObject;
    /** @private */
    private static var _functions:Vector.<Object>;

    /**
     * 初始化，绑定用于侦听帧事件的根容器。
     * @param root 根 Sprite（需已在舞台上以便取 frameRate）。
     * @example
     * <listing version="3.0">
     * KyoTimeout.init(this);
     * </listing>
     */
    public static function init(root:Sprite):void {
        _root      = root;
        _functions = new Vector.<Object>();
    }

    /**
     * 在指定帧数之后调用。
     * @param func 回调。
     * @param frame 等待帧数。
     * @param param 传给回调的参数。
     * @example
     * <listing version="3.0">
     * KyoTimeout.setFrameout(onReady, 30);
     * </listing>
     */
    public static function setFrameout(func:Function, frame:int, ...param):void {
        _functions.push({func: func, frame: frame, param: param});
        setLisnter();
    }

    /**
     * 在指定毫秒后调用（按舞台帧率换算为帧）。
     * @param func 回调。
     * @param time 毫秒。
     * @param param 传给回调的参数。
     * @example
     * <listing version="3.0">
     * KyoTimeout.setTimeout(onReady, 1000);
     * </listing>
     */
    public static function setTimeout(func:Function, time:int, ...param):void {
        var frame:int    = Math.ceil((time / 1000) * _root.stage.frameRate);
        var params:Array = [func, frame].concat(param);
        setFrameout.apply(null, params);
    }

    /**
     * @private
     */
    private static function setLisnter():void {
        _root.removeEventListener(Event.ENTER_FRAME, onEnterframe);
        _root.addEventListener(Event.ENTER_FRAME, onEnterframe);
    }

    /**
     * @private
     */
    private static function onEnterframe(e:Event):void {
        var i:int;
        var n:int = _functions.length;

        if (n < 1) {
            _root.removeEventListener(Event.ENTER_FRAME, onEnterframe);
            return;
        }

        for (i = 0; i < n; i++) {
            var fo:Object = _functions[i];

            if (!fo) {
                _functions.splice(i, 1);
                i = 0;
                n = _functions.length;
                continue;
            }

            var func:Function = fo.func;
            var param:Array   = fo.param;

            if (fo.frame-- <= 0) {
                if (param && param.length > 0) {
                    func.apply(null, param);
                }
                else {
                    func();
                }
                _functions[i] = null;
            }

        }

    }

}
}
