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
 * 命名占位符字符串格式化。
 *
 * @see #formatNamed()
 */
public class KyoStringFormat {
    /**
     * 使用命名占位符 <code>{name}</code> 格式化字符串。
     *
     * <p>字面量大括号写作 <code>{{</code> 与 <code>}}</code>。
     * 占位符名须符合 <code>[A-Za-z_][A-Za-z0-9_]*</code>；个数不限，单次线性扫描。</p>
     *
     * @param format 源字符串；空或无 <code>{</code> 时原样返回。
     * @param params 占位符名到替换值的映射；可为 <code>null</code>（视为空对象）。
     * @return 格式化后的字符串。
     * @throws ArgumentError 模板含命名占位符而 <code>params</code> 缺对应键。
     * @example
     * <listing version="3.0">
     * var out:String = KyoStringFormat.formatNamed('hi {name}', {name: 'a'});
     * </listing>
     */
    public static function formatNamed(format:String, params:Object = null):String {
        if (!format) {
            return format;
        }

        var len:int = format.length;
        if (len == 0 || format.indexOf('{') == -1) {
            return format;
        }

        params ||= {};

        var hasEscape:Boolean = format.indexOf('{{') != -1 || format.indexOf('}}') != -1;

        var parts:Array      = [];
        var missing:Array    = null;
        var i:int            = 0;
        var literalStart:int = 0;
        var replaced:Boolean = false;

        while (i < len) {
            var c:int = format.charCodeAt(i);

            if (hasEscape && c == 0x7D) {
                if (i + 1 < len && format.charCodeAt(i + 1) == 0x7D) {
                    parts[parts.length] = format.substring(literalStart, i);
                    parts[parts.length] = '}';
                    i                  += 2;
                    literalStart        = i;
                    replaced            = true;
                    continue;
                }
            }

            if (c != 0x7B) {
                i++;
                continue;
            }

            if (hasEscape && i + 1 < len && format.charCodeAt(i + 1) == 0x7B) {
                parts[parts.length] = format.substring(literalStart, i);
                parts[parts.length] = '{';
                i                  += 2;
                literalStart        = i;
                replaced            = true;
                continue;
            }

            var nameStart:int = i + 1;
            if (nameStart >= len) {
                i++;
                continue;
            }

            var nc:int = format.charCodeAt(nameStart);
            if (nc != 95 && (nc < 65 || nc > 90) && (nc < 97 || nc > 122)) {
                i++;
                continue;
            }

            var j:int = nameStart + 1;
            var cc:int;
            while (j < len) {
                cc = format.charCodeAt(j);
                if (cc == 95 || (cc >= 65 && cc <= 90) || (cc >= 97 && cc <= 122) || (cc >= 48 && cc <= 57)) {
                    j++;
                }
                else {
                    break;
                }
            }

            if (j >= len || format.charCodeAt(j) != 0x7D) {
                i++;
                continue;
            }

            var name:String     = format.substring(nameStart, j);
            parts[parts.length] = format.substring(literalStart, i);
            replaced            = true;

            if (!(name in params)) {
                if (!missing) {
                    missing = [];
                }
                missing[missing.length] = name;
                parts[parts.length] = '{' + name + '}';
            }
            else {
                var val:*           = params[name];
                parts[parts.length] = val is String ? val as String : String(val);
            }

            i            = j + 1;
            literalStart = i;
        }

        if (!replaced) {
            return format;
        }

        parts[parts.length] = format.substring(literalStart);

        if (missing != null && missing.length > 0) {
            throw new ArgumentError(
                'Format: missing parameter(s): ' + missing.join(', ')
            );
        }

        return parts.join('');
    }

}
}
