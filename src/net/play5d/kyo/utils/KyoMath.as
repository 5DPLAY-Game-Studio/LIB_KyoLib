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
import flash.geom.Point;
import flash.geom.Rectangle;

/**
 * 常用数值与几何计算。
 */
public class KyoMath {
    /** @private 度转弧度系数 */
    private static const DEGTORAD:Number = Math.PI / 180;

    /** 可转换罗马数字的最大整数（含） */
    public static const MAX_ROMAN:int = 3999;
    /** 可转换罗马数字的最小整数（含） */
    public static const MIN_ROMAN:int = 1;

    /**
     * @private 各位罗马数字表：个/十/百/千。
     * 使用 Unicode 罗马数字字形。
     */
    private static const ROMAN_DIGITS:Array = [
        ['', 'Ⅰ', 'Ⅱ', 'Ⅲ', 'Ⅳ', 'Ⅴ', 'Ⅵ', 'Ⅶ', 'Ⅷ', 'Ⅸ'],
        ['', 'Ⅹ', 'ⅩⅩ', 'ⅩⅩⅩ', 'ⅩⅬ', 'Ⅼ', 'ⅬⅩ', 'ⅬⅩⅩ', 'ⅬⅩⅩⅩ', 'ⅩⅭ'],
        ['', 'Ⅽ', 'ⅭⅭ', 'ⅭⅭⅭ', 'ⅭⅮ', 'Ⅾ', 'ⅮⅭ', 'ⅮⅭⅭ', 'ⅮⅭⅭⅭ', 'ⅭⅯ'],
        ['', 'Ⅿ', 'ⅯⅯ', 'ⅯⅯⅯ']
    ];

    /**
     * 将数字钳制在 [min, max]。
     *
     * @param number 原值。
     * @param min 最小值。
     * @param max 最大值。
     * @return 钳制后的值。
     * @example
     * <listing version="3.0">
     * KyoMath.fixRange(1.5, 0, 1); // 1
     * </listing>
     * @see #fixRangeByPoint()
     */
    public static function fixRange(number:Number, min:Number, max:Number):Number {
        if (number < min) {
            return min;
        }
        if (number > max) {
            return max;
        }
        return number;
    }

    /**
     * 判断数字是否在 [min, max] 内（含边界）。
     *
     * <p>端点需有序；无序端点见 <code>isBetween</code>。</p>
     *
     * @param number 原值。
     * @param min 最小值。
     * @param max 最大值。
     * @return 是否在范围内。
     * @example
     * <listing version="3.0">
     * KyoMath.inRange(5, 0, 10); // true
     * </listing>
     * @see #isBetween()
     */
    public static function inRange(number:Number, min:Number, max:Number):Boolean {
        return number >= min && number <= max;
    }

    /**
     * 保留指定小数位。
     * @param num 原数字。
     * @param n 小数位数。
     * @param mathFun 取整函数，默认 <code>Math.round</code>。
     * @return 处理后的数。
     * @example
     * <listing version="3.0">
     * KyoMath.decimal(1.2345, 2); // 1.23
     * </listing>
     */
    public static function decimal(num:Number, n:int, mathFun:Function = null):Number {
        mathFun ||= Math.round;
        var tn:int = Math.pow(10, n);

        return mathFun(num * tn) / tn;
    }

    /**
     * 平均值。
     * @param params 一个数组，或多个数字。
     * @return 平均值。
     * @example
     * <listing version="3.0">
     * KyoMath.average(1, 2, 3); // 2
     * </listing>
     */
    public static function average(...params):Number {
        var array:Array = params[0] is Array ? params[0] : params;
        var num:Number  = sum(array);

        return num / array.length;
    }

    /**
     * 总和。
     * @param params 一个数组，或多个数字。
     * @return 总和。
     * @example
     * <listing version="3.0">
     * KyoMath.sum([1, 2, 3]); // 6
     * </listing>
     */
    public static function sum(...params):Number {
        var array:Array = params[0] is Array ? params[0] : params;
        var num:Number  = 0;
        for each (var i:Number in array) {
            num += i;
        }

        return num;
    }

    /**
     * 计算两点间的角度（度）。
     * @param A 起点。
     * @param B 终点。
     * @return 角度。
     * @example
     * <listing version="3.0">
     * var a:int = KyoMath.getAngleByPoints(p1, p2);
     * </listing>
     */
    public static function getAngleByPoints(A:Point, B:Point):int {
        var xx:Number         = B.x - A.x;
        var yy:Number         = B.y - A.y;
        var hypotenuse:Number = Math.sqrt(xx * xx + yy * yy);
        var radian:Number     = Math.acos(xx / hypotenuse);
        var angle:Number      = 180 / (Math.PI / radian);
        if (yy < 0) {
            return -angle;
        }

        return angle;
    }

    /**
     * 计算两点间的距离。
     * @param A 点 A。
     * @param B 点 B。
     * @return 距离。
     * @example
     * <listing version="3.0">
     * var d:Number = KyoMath.getDistanceByPoints(p1, p2);
     * </listing>
     */
    public static function getDistanceByPoints(A:Point, B:Point):Number {
        var xx:Number = A.x - B.x;
        var yy:Number = A.y - B.y;
        return Math.sqrt(xx * xx + yy * yy);
    }

    /**
     * 按弧度旋转点（可选 y 轴缩放）。
     * @param point 原点。
     * @param radians 弧度。
     * @param scale y 分量缩放。
     * @return 新点。
     * @example
     * <listing version="3.0">
     * var p:Point = KyoMath.getPointByRadians(pt, Math.PI / 2);
     * </listing>
     */
    public static function getPointByRadians(point:Point, radians:Number, scale:Number = 1):Point {
        var rp:Point = new Point();
        rp.x         = point.x * Math.cos(radians) - point.y * Math.sin(radians) * scale;
        rp.y         = point.x * Math.sin(radians) + point.y * Math.cos(radians) * scale;

        return rp;
    }

    /**
     * 角度转弧度。
     * @param degrees 角度。
     * @return 弧度。
     * @example
     * <listing version="3.0">
     * KyoMath.asRadians(180); // Math.PI
     * </listing>
     */
    public static function asRadians(degrees:Number):Number {
        return degrees * DEGTORAD;
    }

    /**
     * 由角度与速率得到速度向量。
     * @param angle 角度或弧度（由 <code>isDegree</code> 决定）。
     * @param speed 速率。
     * @param isDegree 为 <code>true</code> 时 angle 为角度。
     * @return 速度点（分量取整）。
     * @example
     * <listing version="3.0">
     * var v:Point = KyoMath.velocityFromAngle(45, 10);
     * </listing>
     */
    public static function velocityFromAngle(angle:int, speed:int, isDegree:Boolean = true):Point {
        var a:Number = isDegree ? asRadians(angle) : angle;

        var result:Point = new Point();

        result.x = int(Math.cos(a) * speed);
        result.y = int(Math.sin(a) * speed);

        return result;
    }

    /**
     * 整数转罗马数字。
     * @param number 范围 <code>[MIN_ROMAN, MAX_ROMAN]</code>。
     * @return 罗马数字字符串；超出范围则为 <code>null</code>。
     * @example
     * <listing version="3.0">
     * KyoMath.int2roman(8); // 'Ⅷ'
     * KyoMath.int2roman(0); // null
     * </listing>
     * @see #MIN_ROMAN
     * @see #MAX_ROMAN
     */
    public static function int2roman(number:int):String {
        if (number < MIN_ROMAN || number > MAX_ROMAN) {
            return null;
        }

        var roman:String = '';
        for (var i:int = 0; number > 0; i++) {
            roman  = ROMAN_DIGITS[i][number % 10] + roman;
            number = int(number / 10);
        }

        return roman;
    }

    /** @private 向零截断取整 */
    private static function truncateTowardZero(n:Number):Number {
        return n > 0 ? Math.floor(n) : Math.ceil(n);
    }

    /**
     * 判断数值是否落在两端点之间（顺序无关）。
     *
     * @param num 待测值。
     * @param num1 端点一。
     * @param num2 端点二。
     * @return 是否在区间内。
     * @example
     * <listing version="3.0">
     * KyoMath.isBetween(5, 0, 10);
     * </listing>
     * @see #inRange()
     */
    public static function isBetween(num:Number, num1:Number, num2:Number):Boolean {
        if (num1 <= num2) {
            return KyoMath.inRange(num, num1, num2);
        }
        return KyoMath.inRange(num, num2, num1);
    }

    /**
     * 向零衰减：正数减 k、负数加 k，越过 0 则置 0。
     * @param n 原值。
     * @param k 衰减量。
     * @return 结果。
     * @example
     * <listing version="3.0">
     * KyoMath.weaken(10, 3);
     * </listing>
     */
    public static function weaken(n:Number, k:Number):Number {
        if (n > 0) {
            n -= k;
            if (n < 0) {
                n = 0;
            }
        }
        if (n < 0) {
            n += k;
            if (n > 0) {
                n = 0;
            }
        }

        return n;
    }

    /**
     * 沿符号方向增强绝对值。
     * @param n 原值。
     * @param k 增量。
     * @return 结果。
     * @example
     * <listing version="3.0">
     * KyoMath.strengthen(-2, 1); // -3
     * </listing>
     */
    public static function strengthen(n:Number, k:Number):Number {
        if (n < 0) {
            n -= k;
        }
        else {
            n += k;
        }

        return n;
    }

    /**
     * 将数值钳制在 Point 表示的 [x, y] 范围。
     *
     * @param n 原值。
     * @param range x=min，y=max。
     * @return 钳制后的值。
     * @example
     * <listing version="3.0">
     * KyoMath.fixRangeByPoint(v, new Point(0, 1));
     * </listing>
     * @see #fixRange()
     */
    public static function fixRangeByPoint(n:Number, range:Point):Number {
        return fixRange(n, range.x, range.y);
    }

    /**
     * 将点坐标钳制到矩形（宽高当作右/下边界）。
     * @param p 点（原地修改）。
     * @param range 范围矩形。
     * @example
     * <listing version="3.0">
     * KyoMath.fixPointRange(pt, rect);
     * </listing>
     */
    public static function fixPointRange(p:Point, range:Rectangle):void {
        if (p.x < range.x) {
            p.x = range.x;
        }
        if (p.x > range.width) {
            p.x = range.width;
        }
        if (p.y < range.y) {
            p.y = range.y;
        }
        if (p.y > range.height) {
            p.y = range.height;
        }
    }

    /**
     * 将小数转化为百分比形式。
     * @param v 小数。
     * @param decimalPlaces 小数位数，-1 时不限制，0 时为整数。
     * @return 百分比字符串。
     * @example
     * <listing version="3.0">
     * KyoMath.toPercent(0.25); // '25%'
     * </listing>
     */
    public static function toPercent(v:Number, decimalPlaces:int = -1):String {
        var vv:Number = v * 1000 / 10;
        if (decimalPlaces == -1) {

        }
        else if (decimalPlaces == 0) {
            vv = int(vv);
        }
        else {
            vv = decimal(vv, decimalPlaces, truncateTowardZero);
        }

        return vv.toString() + '%';
    }

    /**
     * 比较两点是否完全相同。
     * @param A 点 A。
     * @param B 点 B。
     * @return 是否相等。
     * @example
     * <listing version="3.0">
     * KyoMath.matchPoint(p1, p2);
     * </listing>
     */
    public static function matchPoint(A:Point, B:Point):Boolean {
        if (!A || !B) {
            return false;
        }

        return A.x == B.x && A.y == B.y;
    }

    /**
     * 比较两矩形是否完全相同。
     * @param A 矩形 A。
     * @param B 矩形 B。
     * @return 是否相等。
     * @example
     * <listing version="3.0">
     * KyoMath.matchRectangle(r1, r2);
     * </listing>
     */
    public static function matchRectangle(A:Rectangle, B:Rectangle):Boolean {
        if (!A || !B) {
            return false;
        }

        return A.x == B.x && A.y == B.y && A.width == B.width && A.height == B.height;
    }

    /**
     * 求两矩形相交区域；无相交则 <code>null</code>（会规范化负宽高）。
     * @param rectA 矩形 A。
     * @param rectB 矩形 B。
     * @return 相交矩形或 <code>null</code>。
     * @example
     * <listing version="3.0">
     * var hit:Rectangle = KyoMath.rectHit(a, b);
     * </listing>
     */
    public static function rectHit(rectA:Rectangle, rectB:Rectangle):Rectangle {
        function checkRect(rect:Rectangle):void {
            if (rect.width < 0) {
                rect.width *= -1;
                rect.x -= rect.width;
            }
            if (rect.height < 0) {
                rect.height *= -1;
                rect.y -= rect.height;
            }
        }

        checkRect(rectA);
        checkRect(rectB);

        var r:Rectangle = rectA.intersection(rectB);
        if (!r.isEmpty()) {
            return r;
        }

        return null;
    }

}
}
