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
import flash.geom.Point;

/**
 * 按自定义注册点设置显示对象属性（旋转 / 缩放时保持注册点视觉位置）。
 *
 * @see #flush()
 */
public class DynamicRegistration {
    /**
     * @param target 目标显示对象。
     * @param regPoint 本地坐标系下的注册点。
     */
    public function DynamicRegistration(target:DisplayObject, regPoint:Point) {
        _target   = target;
        _regPoint = regPoint;
    }

    /** @private 注册点（本地坐标） */
    private var _regPoint:Point;
    /** @private */
    private var _target:DisplayObject;

    /**
     * 设置属性；非 x/y 时会补偿位移以固定注册点。
     * @param prop 属性名（如 <code>x</code>、<code>y</code>、<code>rotation</code>、<code>scaleX</code>）。
     * @param value 新值。
     * @example
     * <listing version="3.0">
     * reg.flush('rotation', 45);
     * </listing>
     */
    public function flush(prop:String, value:Number):void {
        var mc:DisplayObject = _target;
        // 转换为全局坐标
        var a:Point          = mc.parent.globalToLocal(mc.localToGlobal(_regPoint));

        if (prop == 'x' || prop == 'y') {
            mc[prop] = value - _regPoint[prop];
        }
        else {
            mc[prop] = value;
            // 执行旋转等属性后，再重新计算全局坐标
            var b:Point = mc.parent.globalToLocal(mc.localToGlobal(_regPoint));
            // 把注册点从 b 移到 a
            mc.x += a.x - b.x;
            mc.y += a.y - b.y;
        }
    }
}
}
