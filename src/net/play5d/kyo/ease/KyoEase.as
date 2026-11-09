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

package net.play5d.kyo.ease {
import flash.display.DisplayObject;
import flash.events.Event;
import flash.geom.Point;

/**
 * 缓动 / 运动工具（静态方法）。
 *
 * <p>当前仅提供抛物线位移；水平按 <code>speed</code> 正向累加，适用于目标在右侧的情形。</p>
 *
 * @see #parabola()
 */
public class KyoEase {
    /**
     * 抛物线运动：水平正向匀速，垂直受重力加速，越过目标点后回调。
     *
     * <p>垂直初速度向上，轨迹先升后降。<code>x</code> 与 <code>y</code> 都大于目标后，移除本次 <code>ENTER_FRAME</code> 并调用回调。重复调用会叠加监听。</p>
     *
     * @param display 要移动的显示对象。
     * @param target 目标坐标（通常 <code>x</code> 大于起点）。
     * @param speed 水平速度（像素/帧，正向），默认 10。
     * @param g 每帧叠加的垂直速度（像素/帧²，向下为正），默认 1。
     * @param callBack 到达条件满足时的无参回调；为 <code>null</code> 时忽略。
     * @example
     * <listing version="3.0">
     * KyoEase.parabola(ball, new Point(400, 300), 8, 1, onLand);
     * </listing>
     */
    public static function parabola(
        display :DisplayObject,
        target  :Point,
        speed   :Number = 10,
        g       :Number = 1,
        callBack:Function = null
    ):void {
        var distance:Number = Math.abs(target.x - display.x);
        var time:int        = distance / speed;
        var spdY:Number     = -time / 2 * g;

        display.addEventListener(Event.ENTER_FRAME, onEnterFrame);

        function onEnterFrame(e:Event):void {
            display.x += speed;
            display.y += spdY;
            spdY += g;

            if (display.x > target.x && display.y > target.y) {
                display.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
                if (callBack != null) {
                    callBack();
                }
            }
        }
    }
}
}
