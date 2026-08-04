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
/**
 * 以 id 为键的轻量字典，并维护元素个数 <code>length</code>。
 *
 * @see ArrayMap
 * @see #push()
 * @see #getItem()
 */
public class ArrayLite {
    /**
     * 当前键值对数量。
     * @default 0
     */
    public var length:int;
    /** @private */
    private var _o:Object = {};

    /**
     * 写入或覆盖一项；新键时 <code>length</code> 加一。
     * @param id 键。
     * @param value 值。
     * @example
     * <listing version="3.0">
     * lite.push('a', 1);
     * </listing>
     */
    public function push(id:Object, value:*):void {
        if (!_o[id]) {
            length++;
        }
        _o[id] = value;
    }

    /**
     * 按键取值。
     * @param id 键。
     * @return 值；无则 <code>undefined</code>。
     * @example
     * <listing version="3.0">
     * var v:* = lite.getItem('a');
     * </listing>
     */
    public function getItem(id:Object):* {
        return _o[id];
    }

    /**
     * 按键删除；存在时 <code>length</code> 减一。
     * @param id 键。
     * @example
     * <listing version="3.0">
     * lite.remove('a');
     * </listing>
     */
    public function remove(id:Object):void {
        if (!_o[id]) {
            return;
        }

        delete _o[id];
        length--;
        if (length < 0) {
            length = 0;
        }
    }
}
}
