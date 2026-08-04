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
 * 将阿拉伯数字金额转为中文大写。
 *
 * @see #toCNUpper()
 * @author marcoLee
 */
public class MoneyUtils {
    /** 中文大写数字 0~9。 */
    public static const NUM_CN:Array        = ['零', '壹', '贰', '叁', '肆', '伍', '陆', '柒', '捌', '玖'];
    /** 小数单位：角、分。 */
    public static const DECIMAL_UNITS:Array = ['角', '分'];
    /** 节权：元、万、亿、兆。 */
    public static const LEVELS:Array        = ['元', '万', '亿', '兆'];
    /** 千百十。 */
    public static const UNITS:Array         = ['千', '百', '拾'];

    /**
     * 把阿拉伯数字转换成中文大写金额。
     * @param num 阿拉伯数字。
     * @return 中文大写。
     * @throws Error 整数部分超过 16 位。
     * @example
     * <listing version="3.0">
     * MoneyUtils.toCNUpper(12.34);
     * </listing>
     */
    public static function toCNUpper(num:Number):String {
        if (num == 0) {
            return NUM_CN[0];
        }

        var numStr:String   = num.toFixed(2);
        var pos:int         = numStr.indexOf('.');
        var dotLeft:String  = pos == -1 ? numStr : numStr.substring(0, pos);
        var dotRight:String = pos == -1 ? '' : numStr.substring(pos + 1, numStr.length);
        if (dotLeft.length > 16) {
            throw new Error('数字太大，无法处理！');
        }

        return convertIntegerStr(dotLeft) + convertDecimalStr(dotRight);
    }

    /**
     * 转换整数部分字符串。
     * @param str 整数字符串。
     * @return 中文大写整数段。
     * @example
     * <listing version="3.0">
     * MoneyUtils.convertIntegerStr('1234');
     * </listing>
     */
    public static function convertIntegerStr(str:String):String {
        var tCount:int  = Math.floor(str.length / 4);
        var rCount:int  = str.length % 4;
        var nodes:Array = [];
        if (rCount > 0) {
            nodes.push(convertThousand(str.substr(0, rCount), tCount));
        }

        for (var i:int = 0; i < tCount; i++) {
            var startIndex:int = rCount + i * 4;
            var num:String     = str.substring(startIndex, startIndex + 4);
            nodes.push(convertThousand(num, tCount - i - 1));
        }

        return convertNodes(nodes);
    }

    /**
     * 转换小数部分字符串。
     * @param str 小数数字符串。
     * @return 角分中文。
     * @example
     * <listing version="3.0">
     * MoneyUtils.convertDecimalStr('34');
     * </listing>
     */
    public static function convertDecimalStr(str:String):String {
        var newStr:String = '';
        for (var i:int = 0; i < str.length; i++) {
            var n:int = int(str.charAt(i));
            if (n > 0) {
                newStr += NUM_CN[n] + DECIMAL_UNITS[i];
            }
        }

        return newStr;
    }

    /**
     * 用对数估算整数位数。
     * @param num 数字。
     * @return 位数。
     * @example
     * <listing version="3.0">
     * MoneyUtils.getUnitCount(100);
     * </listing>
     */
    public static function getUnitCount(num:Number):int {
        return Math.ceil(Math.log(num) / Math.LN10);
    }

    /** @private */
    private static function convertNodes(nodes:Array):String {
        var str:String = '';
        var beforeZero:Boolean;
        for (var i:int = 0; i < nodes.length; i++) {
            var node:ThousandNode = nodes[i] as ThousandNode;
            if ((beforeZero && node.desc.length > 0) ||
                (node.beforeZero && node.desc.length > 0 && str.length > 0)) {
                str += NUM_CN[0];
            }

            str += node.desc;
            if (node.afterZero && i < nodes.length - 1) {
                beforeZero = true;
            }
            else if (node.desc.length > 0) {
                beforeZero = false;
            }
        }

        return str;
    }

    /** @private 对四位数进行处理，不够自动补齐。 */
    private static function convertThousand(num:String, level:int):ThousandNode {
        var node:ThousandNode = new ThousandNode();
        var len:int           = num.length;

        for (var i:int = 0; i < 4 - len; i++) {
            num = '0' + num;
        }

        var n1:int = int(num.charAt(0));
        var n2:int = int(num.charAt(1));
        var n3:int = int(num.charAt(2));
        var n4:int = int(num.charAt(3));

        if (n1 + n2 + n3 + n4 == 0) {
            return node;
        }

        if (n1 == 0) {
            node.beforeZero = true;
        }
        else {
            node.desc += NUM_CN[n1] + UNITS[0];
        }

        if (n2 == 0 && node.desc != '' && n3 + n4 > 0) {
            node.desc += NUM_CN[0];
        }
        else if (n2 > 0) {
            node.desc += NUM_CN[n2] + UNITS[1];
        }

        if (n3 == 0 && node.desc != '' && n4 > 0) {
            node.desc += NUM_CN[0];
        }
        else if (n3 > 0) {
            node.desc += NUM_CN[n3] + UNITS[2];
        }

        if (n4 == 0) {
            node.afterZero = true;
        }
        else if (n4 > 0) {
            node.desc += NUM_CN[n4];
        }

        if (node.desc.length > 0) {
            node.desc += LEVELS[level];
        }

        return node;
    }

}
}

/**
 * 千位节节点（文件内）。
 */
class ThousandNode {
    /**
     * 构造函数。
     */
    public function ThousandNode() {
    }

    /**
     * 节前是否需补零。
     */
    public var beforeZero:Boolean;
    /**
     * 节后是否需补零。
     */
    public var afterZero:Boolean;
    /**
     * 本节点描述。
     * @default ''
     */
    public var desc:String = '';
}
