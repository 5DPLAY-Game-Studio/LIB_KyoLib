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
import flash.geom.Point;

/**
 * 常用数值与几何计算。
 *
 * @see #fixRange()
 * @see #getDistanceByPoints()
 * @see #velocityFromAngle()
 */
public class KyoMath {
    /** @private 度转弧度系数 */
    private static const DEGTORAD:Number = Math.PI / 180;

    /**
     * 将数字钳制在 [min, max]。
     * @param number 原值。
     * @param min 最小值。
     * @param max 最大值。
     * @return 钳制后的值。
     * @example
     * <listing version="3.0">
     * KyoMath.fixRange(1.5, 0, 1); // 1
     * </listing>
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
     * @param number 原值。
     * @param min 最小值。
     * @param max 最大值。
     * @return 是否在范围内。
     * @example
     * <listing version="3.0">
     * KyoMath.inRange(5, 0, 10); // true
     * </listing>
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
        for each(var i:Number in array) {
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
     * @param radious 弧度（历史拼写）。
     * @param scale y 分量缩放。
     * @return 新点。
     * @example
     * <listing version="3.0">
     * var p:Point = KyoMath.getPointByRadians(pt, Math.PI / 2);
     * </listing>
     */
    public static function getPointByRadians(point:Point, radious:Number, scale:Number = 1):Point {
        var rp:Point = new Point();
        rp.x         = point.x * Math.cos(radious) - point.y * Math.sin(radious) * scale;
        rp.y         = point.x * Math.sin(radious) + point.y * Math.cos(radious) * scale;
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

}
}
