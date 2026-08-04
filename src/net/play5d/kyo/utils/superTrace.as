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
 * 带调用栈方法名的 <code>trace</code>。
 *
 * @param args 输出参数。
 * @example
 * <listing version="3.0">
 * superTrace('value', 1);
 * </listing>
 */
public function superTrace(...args):void {
    var e:Error = new Error();
    var stack:String = e.getStackTrace();
    var matches:Array = stack ? stack.match(/[\w\/]*\(\)/g) : null;
    var caller:String = matches && matches.length > 1 ? '[' + matches[1] + ']' : '[?]';
    trace(caller, args);
}
}
