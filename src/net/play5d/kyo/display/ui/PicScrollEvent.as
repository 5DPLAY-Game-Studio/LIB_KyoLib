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

package net.play5d.kyo.display.ui {
import flash.events.Event;

/**
 * <code>PicScroller</code> 相关事件。
 *
 * @see PicScroller
 * @see #data
 */
public class PicScrollEvent extends Event {
    /**
     * <code>CHANGE</code> 事件的 <code>type</code> 属性值。
     * @eventType CHANGE
     */
    public static const CHANGE:String = 'CHANGE';
    /**
     * <code>CHANGE_COMPLETE</code> 事件的 <code>type</code> 属性值。
     * @eventType CHANGE_COMPLETE
     */
    public static const CHANGE_COMPLETE:String = 'CHANGE_COMPLETE';
    /**
     * <code>MOUSE_UP</code> 事件的 <code>type</code> 属性值。
     * @eventType MOUSE_UP
     */
    public static const MOUSE_UP:String = 'MOUSE_UP';

    /**
     * @param type 事件类型。
     * @param data 附加数据（通常为当前页索引），可选。
     */
    public function PicScrollEvent(type:String, data:Object = null) {
        super(type, false, false);
        this.data = data;
    }

    /**
     * 事件附带数据。
     * @default null
     */
    public var data:Object;
}
}
