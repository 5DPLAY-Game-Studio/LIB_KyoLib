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
import com.adobe.utils.StringUtil;
import flash.utils.ByteArray;

/**
 * 字符串、路径后缀与数字文本格式化。
 */
public class KyoStringUtils {
/**
     * 在数字前补 0 至指定整数位数（小数部分保留）。
     * @param n 数字。
     * @param bit 整数部分目标位数，默认 2。
     * @return 补零后的字符串。
     * @example
     * <listing version="3.0">
     * KyoStringUtils.padNumber(1, 3); // '001'
     * </listing>
     * @see net.play5d.kyo.utils.KyoTimerFormat#formatNum()
     */
    public static function padNumber(n:Number, bit:int = 2):String {
        var nstr:String    = n.toString();
        var ii:int         = nstr.indexOf('.', 0);
        var after0:String  = ii == -1 ? '' : nstr.substr(ii);
        var before0:String = ii == -1 ? nstr : nstr.substr(0, ii);
        var zeros:String   = '';
        for (var i:int; i < bit - before0.length; i++) {
            zeros += '0';
        }
        return zeros + before0 + after0;
    }

/**
     * 取 URL / 路径的扩展名（小写，不含点；忽略 <code>?</code> / <code>#</code> 查询与锚点）。
     * @param v 完整 URL 或文件路径。
     * @return 扩展名；无扩展名时为空串。
     * @example
     * <listing version="3.0">
     * KyoStringUtils.getExtension('a/b.PNG?x=1'); // 'png'
     * </listing>
     * @see #getPostfix()
     * @see #getPrefix()
     */
    public static function getExtension(v:String):String {
        if (!v) {
            return '';
        }
        var path:String = v;
        var q:int       = path.indexOf('?');
        if (q != -1) {
            path = path.substring(0, q);
        }
        var h:int = path.indexOf('#');
        if (h != -1) {
            path = path.substring(0, h);
        }
        var slash:int = Math.max(path.lastIndexOf('/'), path.lastIndexOf('\\'));
        var i:int     = path.lastIndexOf('.');
        if (i == -1 || i <= slash || i == path.length - 1) {
            return '';
        }
        return path.substring(i + 1).toLowerCase();
    }

/**
     * 获取 URL 的后缀名（委托 <code>getExtension</code>）。
     * @param v URL 或路径。
     * @return 扩展名小写串。
     * @example
     * <listing version="3.0">
     * KyoStringUtils.getPostfix('a.jpg?v=1'); // 'jpg'
     * </listing>
     * @see #getExtension()
     */
    public static function getPostfix(v:String):String {
        return getExtension(v);
    }

/**
     * 整数转中文数字（简易，支持到万）。
     * @param n 非负整数。
     * @return 中文数字串。
     * @example
     * <listing version="3.0">
     * KyoStringUtils.number2CN(21); // '二十一'
     * </listing>
     */
    public static function number2CN(n:int):String {
        var w:int, q:int, b:int, s:int;
        var r:String = '';
        if (n >= 10000) {
            w = int(n / 10000);
            n -= 10000;
            r += num2cnbase(w) + '万';
        }
        if (n >= 1000) {
            q = int(n / 1000);
            n -= 1000;
            r += num2cnbase(q) + '千';
        }
        else if (w > 0) {
            r += '零';
        }
        if (n >= 100) {
            b = int(n / 100);
            n -= b * 100;
            r += num2cnbase(b) + '百';
        }
        if (n >= 10) {
            s = int(n / 10);
            n -= s * 10;
            if (b > 0) {
                if (s > 0) {
                    r += num2cnbase(s) + '十';
                }
            }
            if (b == 0) {
                if (s == 1) {
                    r += '十';
                }
                if (s > 1) {
                    r += num2cnbase(s) + '十';
                }
            }
        }
        if (n > 0 && s == 0 && b > 0) {
            r += '零';
        }
        r += num2cnbase(n, r == '');
        return r;
    }

    /**
     * @private 个位中文。
     */
    private static function num2cnbase(n:int, showZero:Boolean = true):String {
        if (!showZero && n == 0) {
            return '';
        }
        var vv:Array = ['零', '一', '二', '三', '四', '五', '六', '七', '八', '九'];
        return vv[n];
    }

/**
     * 获取字符串的字节数。
     * @param str 字符串。
     * @param encode 编码方式。
     * @return 字节数。
     * @example
     * <listing version="3.0">
     * var n:int = KyoStringUtils.byteLength('你好');
     * </listing>
     */
    public static function byteLength(str:String, encode:String = 'gb2312'):int {
        var bt:ByteArray = new ByteArray();
        bt.writeMultiByte(str, encode);
        return bt.length;
    }

/**
     * 去除后缀名。
     * @param v 带扩展名的字符串。
     * @return 去掉首个 <code>.</code> 及之后部分的字符串。
     * @example
     * <listing version="3.0">
     * KyoStringUtils.removePrefix('a.png'); // 'a'
     * </listing>
     */
    public static function removePrefix(v:String):String {
        var x:int = v.indexOf('.');
        if (x == -1) {
            return v;
        }
        return v.substr(0, x);
    }

/**
     * 字符串字符替换。
     * @param v 源字符串。
     * @param p 被替换片段。
     * @param repl 替换为。
     * @return 替换后的字符串。
     * @example
     * <listing version="3.0">
     * KyoStringUtils.replaceAll('a-b-c', '-', '_'); // 'a_b_c'
     * </listing>
     */
    public static function replaceAll(v:String, p:*, repl:*):String {
        return v.split(p).join(repl);
    }

/**
     * 反复 match 并收集捕获组（最多一万次）。
     * @param v 源字符串。
     * @param p 正则或匹配模式。
     * @return 捕获结果数组（逆序）。
     * @example
     * <listing version="3.0">
     * var a:Array = KyoStringUtils.matchAll(s, /\{(\w+)\}/);
     * </listing>
     */
    public static function matchAll(v:String, p:*):Array {
        var ra:Array = [];
        for (var i:int; i < 10000; i++) {
            var va:Array = v.match(p);
            if (!va || va.length < 1) {
                break;
            }
            var vs:String = va[1];
            v             = v.replace(vs, '');
            ra.push(vs);
        }
        return ra.reverse();
    }

/**
     * 获取后缀名（委托 <code>getExtension</code>；历史命名保留）。
     * @param v URL 或路径。
     * @return 扩展名小写串。
     * @example
     * <listing version="3.0">
     * KyoStringUtils.getPrefix('a.PNG'); // 'png'
     * </listing>
     * @see #getExtension()
     */
    public static function getPrefix(v:String):String {
        return getExtension(v);
    }

/**
     * 读取字符串格式的变量。
     * 格式为：
     *     变量名=值
     *     变量名=值
     *     //注释
     *     变量名=值
     * @param v 文本内容。
     * @return 键值 Object。
     * @example
     * <listing version="3.0">
     * var o:Object = KyoStringUtils.readTextVariables('a=1\nb=2');
     * </listing>
     */
    public static function readTextVariables(v:String):Object {
        var o:Object = {};

        v            = StringUtil.replace(v, '\r', '');
        var ps:Array = v.split('\n');
        for each(var i:String in ps) {
            if (i.substr(0, 2) == '//') {
                continue;
            }

            var p2:Array  = i.split('=');
            var k:String  = p2[0];
            var vv:Object = p2[1];
            o[k]          = vv;
        }
        return o;
    }

}
}
