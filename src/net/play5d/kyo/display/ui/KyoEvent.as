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
 * Kyo UI 通用事件。
 *
 * @see #CHANGE
 */
public class KyoEvent extends Event {
    /**
     * <code>CHANGE</code> 事件的 <code>type</code> 属性值。
     * @eventType CHANGE
     */
    public static const CHANGE:String = 'kyo-event-change';

    /**
     * @param type 事件类型。
     * @param bubbles 是否冒泡，默认 <code>false</code>。
     * @param cancelable 是否可取消，默认 <code>false</code>。
     */
    public function KyoEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false) {
        super(type, bubbles, cancelable);
    }
}
}
