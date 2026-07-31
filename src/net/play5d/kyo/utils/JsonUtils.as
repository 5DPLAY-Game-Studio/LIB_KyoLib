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
 * JSON 字符串粗判与安全解析。
 *
 * @see #isJsonString()
 * @see #str2json()
 */
public class JsonUtils {
    /**
     * 判断是否像 JSON 对象/数组字符串（首字符为 <code>{</code> 或 <code>[</code>）。
     * @param v 待测值。
     * @return 为字符串且首字符匹配时为 <code>true</code>。
     * @example
     * <listing version="3.0">
     * JsonUtils.isJsonString('{"a":1}'); // true
     * </listing>
     */
    public static function isJsonString(v:Object):Boolean {
        if (v is String) {
            var vs:String = v as String;
            return vs.charAt(0) == '{' || vs.charAt(0) == '[';
        }
        return false;
    }

    /**
     * 将疑似 JSON 字符串解析为对象；失败或非 JSON 形态时返回 <code>null</code>。
     * @param v 源值。
     * @return 解析结果，或 <code>null</code>。
     * @example
     * <listing version="3.0">
     * var o:Object = JsonUtils.str2json('{"a":1}');
     * </listing>
     */
    public static function str2json(v:Object):Object {
        if (isJsonString(v)) {
            var obj:Object;
            try {
                obj = JSON.parse(v as String);
            }
            catch (e:Error) {
                trace(e);
            }
            return obj;
        }
        return null;
    }

    /**
     * 构造函数（本类以静态方法使用，通常无需实例化）。
     */
    public function JsonUtils() {
    }

}
}
