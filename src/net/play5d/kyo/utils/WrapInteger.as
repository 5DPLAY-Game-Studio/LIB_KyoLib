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

/**
 * 以随机 XOR 偏移混淆存储的整数，降低内存中明文可读性。
 *
 * @see #setValue()
 * @see #getValue()
 */
public class WrapInteger {

    /** @private */
    private static var _rndArr:Array = [1, 2, 3, 4, 5, 6, 7, 8, 9];

    /**
     * @param v 初始值。
     */
    public function WrapInteger(v:int) {
        _offset = Math.floor(Math.random() * _rndArr.length);
        _w      = v ^ _rndArr[_offset];
    }

    /** @private */
    private var _w:int;
    /** @private */
    private var _offset:int;

    /**
     * 写入新值（重新随机偏移）。
     * @param v 明文整数。
     */
    public function setValue(v:int):void {
        _offset = Math.floor(Math.random() * _rndArr.length);
        _w      = v ^ _rndArr[_offset];
    }

    /**
     * 读取明文整数。
     * @return 当前值。
     */
    public function getValue():int {
        return _w ^ _rndArr[_offset];
    }

    /**
     * @return 当前值的字符串形式。
     */
    public function toString():String {
        return getValue().toString();
    }
}
}
