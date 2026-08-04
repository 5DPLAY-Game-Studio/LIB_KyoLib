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
/**
 * 按键值对象：名称、keyCode 与按下状态。
 *
 * @see KyoKeyCode
 * @see KyoKeyInput
 */
public class KyoKeyVO {
    /**
     * @param name 键名（映射用）。
     * @param code 键盘 keyCode。
     */
    public function KyoKeyVO(name:String, code:int) {
        this.name = name;
        this.code = code;
    }

    /**
     * 键名。
     */
    public var name:String;
    /**
     * 键盘 keyCode。
     */
    public var code:int;
    /**
     * 当前是否处于按下（由输入管理器维护）。
     * @default false
     */
    public var isDown:Boolean;

    /**
     * @return 键名。
     * @example
     * <listing version="3.0">
     * String(KyoKeyCode.A); // 'A'
     * </listing>
     */
    public function toString():String {
        return name;
    }

    /**
     * 复制名称与 code（不复制 <code>isDown</code>）。
     * @return 新实例。
     * @example
     * <listing version="3.0">
     * var k:KyoKeyVO = KyoKeyCode.A.clone();
     * </listing>
     */
    public function clone():KyoKeyVO {
        return new KyoKeyVO(name, code);
    }
}
}
