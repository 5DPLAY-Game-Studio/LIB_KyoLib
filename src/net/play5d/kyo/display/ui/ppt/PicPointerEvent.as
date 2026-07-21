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

package net.play5d.kyo.display.ui.ppt {
import flash.events.Event;

/**
 * 幻灯片 / 队列加载相关事件。
 *
 * @see PicPointer
 * @see PPTLoaderCtrl
 * @see #data
 */
public class PicPointerEvent extends Event {
    /**
     * <code>CHANGE_START</code> 事件的 <code>type</code> 属性值。
     * @eventType CHANGE_START
     */
    public static const CHANGE_START:String = 'CHANGE_START';
    /**
     * <code>CHANGE_FINISH</code> 事件的 <code>type</code> 属性值。
     * @eventType CHANGE_FINISH
     */
    public static const CHANGE_FINISH:String = 'CHANGE_FINISH';
    /**
     * <code>MOUSE_UP</code> 事件的 <code>type</code> 属性值。
     * @eventType MOUSE_UP
     */
    public static const MOUSE_UP:String = 'MOUSE_UP';
    /**
     * <code>LOAD_PROCESS</code> 事件的 <code>type</code> 属性值。
     * @eventType LOAD_PROCESS
     */
    public static const LOAD_PROCESS:String = 'LOAD_PROCESS';
    /**
     * <code>LOAD_COMPLETE</code> 事件的 <code>type</code> 属性值。
     * @eventType LOAD_COMPLETE
     */
    public static const LOAD_COMPLETE:String = 'LOAD_COMPLETE';

    /**
     * @param type 事件类型。
     * @param data 附加数据（如页索引或进度 0–1），可选。
     */
    public function PicPointerEvent(type:String, data:Object = null) {
        super(type, false, false);
        this.data = data;
    }

    /**
     * 事件附带数据（页索引、加载进度等，视类型而定）。
     * @default null
     */
    public var data:Object;
}
}
