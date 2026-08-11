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

package net.play5d.kyo.input {
import flash.events.Event;

/**
 * 触摸 / 滑动相关事件。
 *
 * @see KyoTouchInput
 * @see #SLIDE
 * @see #direction
 */
public class KyoTouchEvent extends Event {
    /**
     * <code>SLIDE</code> 事件的 <code>type</code> 属性值。
     * @eventType event-slide
     */
    public static const SLIDE:String = 'event-slide';

    /** 向上滑动。 */
    public static const DIRECTION_UP:int    = 0;
    /** 向下滑动。 */
    public static const DIRECTION_DOWN:int  = 6;
    /** 向左滑动。 */
    public static const DIRECTION_LEFT:int  = 9;
    /** 向右滑动。 */
    public static const DIRECTION_RIGHT:int = 3;

    /**
     * 构造触摸事件。
     * @param type 事件类型。
     * @param obj 可选属性字典（键写入本实例，如 <code>direction</code>）。
     * @example
     * <listing version="3.0">
     * dispatchEvent(new KyoTouchEvent(KyoTouchEvent.SLIDE, {direction: KyoTouchEvent.DIRECTION_LEFT}));
     * </listing>
     */
    public function KyoTouchEvent(type:String, obj:Object = null) {
        for (var key:String in obj) {
            this[key] = obj[key];
        }
        super(type, false, false);
    }

    /**
     * 滑动方向，见 <code>DIRECTION_UP</code> 等常量。
     * @default 0
     */
    public var direction:int;
}
}
