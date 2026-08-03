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
 * 同时按 id 与插入顺序索引的映射表。
 *
 * @see ArrayLite
 * @see #push()
 * @see #getItemById()
 * @see #getItemByIndex()
 */
public class ArrayMap {
    /**
     * 构造函数。
     */
    public function ArrayMap() {
        super();
        _o   = {};
        _arr = [];
    }

    /** @private */
    private var _o:Object;
    /** @private */
    private var _arr:Array;

    /**
     * 元素个数（插入顺序数组长度）。
     * @return 元素个数。
     */
    public function get length():int {
        return _arr.length;
    }

    /**
     * 追加一项（按 id 覆盖字典项，并追加到顺序数组）。
     * @param id 键。
     * @param value 值。
     * @example
     * <listing version="3.0">
     * map.push('a', obj);
     * </listing>
     */
    public function push(id:Object, value:*):void {
        _o[id] = value;
        _arr.push(value);
    }

    /**
     * 按插入下标取值。
     * @param index 下标。
     * @return 值。
     * @example
     * <listing version="3.0">
     * var v:* = map.getItemByIndex(0);
     * </listing>
     */
    public function getItemByIndex(index:int):* {
        return _arr[index];
    }

    /**
     * 按 id 取值。
     * @param id 键。
     * @return 值。
     * @example
     * <listing version="3.0">
     * var v:* = map.getItemById('a');
     * </listing>
     */
    public function getItemById(id:Object):* {
        return _o[id];
    }

    /**
     * 按 id 删除（同步从顺序数组移除）。
     * @param id 键。
     * @example
     * <listing version="3.0">
     * map.removeItemById('a');
     * </listing>
     */
    public function removeItemById(id:Object):void {
        if (!_o[id]) {
            return;
        }

        var index:int = _arr.indexOf(_o[id]);
        if (index != -1) {
            _arr.splice(index, 1);
        }

        delete _o[id];

    }
}
}
