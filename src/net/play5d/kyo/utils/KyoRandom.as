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
 * 随机数与随机选取工具。
 *
 * @see #getRandomInArray()
 * @see #between()
 * @see #getRandomByRate()
 */
public class KyoRandom {
    /**
     * 从数组中随机取一个元素。
     * @param array 类数组对象。
     * @param removeSelected 为 <code>true</code> 时从原数组 splice 该项。
     * @return 元素；空数组则 <code>null</code>。
     * @example
     * <listing version="3.0">
     * var v:* = KyoRandom.getRandomInArray([1, 2, 3]);
     * </listing>
     */
    public static function getRandomInArray(array:Object, removeSelected:Boolean = false):* {
        if (array == null || array.length < 1) {
            return null;
        }

        var r:int  = Math.random() * array.length << 0;
        var item:* = array[r];
        if (removeSelected) {
            array.splice(r, 1);
        }

        return item;
    }

    /**
     * 随机取出多个元素。
     * @param array 源数组。
     * @param amount 数量。
     * @param repeat 是否允许重复。
     * @return 结果数组。
     * @example
     * <listing version="3.0">
     * var a:Array = KyoRandom.getRandomSomeInArray(list, 3);
     * </listing>
     */
    public static function getRandomSomeInArray(array:Array, amount:int, repeat:Boolean = false):Array {
        var a:Array = array.concat();
        var r:Array = [];
        for (var i:int = 0; i < amount; i++) {
            var d:int = Math.random() * a.length << 0;
            var m:*   = a[d];
            r.push(m);
            if (!repeat) {
                a.splice(d, 1);
            }
        }

        return r;
    }

    /**
     * 从可变参数中随机取一个。
     * @param params 候选项。
     * @return 随机项。
     * @example
     * <listing version="3.0">
     * var v:* = KyoRandom.getRandomOne('a', 'b', 'c');
     * </listing>
     */
    public static function getRandomOne(...params):* {
        return getRandomInArray(params);
    }

    /**
     * 在两端点之间随机（含边界）。
     * @param a 一端。
     * @param b 另一端。
     * @return 随机数。
     * @example
     * <listing version="3.0">
     * var n:Number = KyoRandom.between(0, 1);
     * </listing>
     */
    public static function between(a:Number, b:Number):Number {
        var s:Number = a < b ? a : b;
        var e:Number = a < b ? b : a;
        var r:Number = s + Math.random() * (e - s);

        return KyoMath.fixRange(r, s, e);
    }

    /**
     * 按权重随机（必选出一项）。
     * @param array 元素对象数组。
     * @param attributeName 权重属性名（Number）。
     * @return 选中元素。
     * @throws Error 无法按权重选出时。
     * @example
     * <listing version="3.0">
     * var o:* = KyoRandom.getRandomByRate(list, 'rate');
     * </listing>
     */
    public static function getRandomByRate(array:Array, attributeName:String):* {
        var max:Number = 0;
        array.sortOn(attributeName, Array.NUMERIC);
        for (var i:int = 0; i < array.length; i++) {
            max += Number(array[i][attributeName]);
        }

        var rand:Number = Math.random() * max;
        if (rand > max - 1) {
            rand = max - 1;
        }

        var rate:Number = 0;
        for (i = 0; i < array.length; i++) {
            var newRate:Number = rate + Number(array[i][attributeName]);
            if (rand >= rate && rand < newRate) {
                return array[i];
            }
            rate = newRate;
        }

        throw new Error('无法按几率选择，请检查数据');
    }

    /**
     * 按权重随机（轻量；可能返回 <code>null</code>）。
     * @param array 元素对象数组。
     * @param attributeName 权重属性名（建议 0~1）。
     * @param randMax 随机上界。
     * @return 选中元素或 <code>null</code>。
     * @example
     * <listing version="3.0">
     * var o:* = KyoRandom.getRandomByRateLite(list, 'rate');
     * </listing>
     */
    public static function getRandomByRateLite(array:Array, attributeName:String, randMax:Number = 1):* {
        array.sortOn(attributeName, Array.NUMERIC);

        var rand:Number = Math.random() * randMax;
        var rate:Number = 0;
        var a:Array     = [];
        for (var i:int = 0; i < array.length; i++) {
            var m:*      = array[i];
            var n:Number = m[attributeName];
            if (rate == 0) {
                if (rand <= n) {
                    rate = n;
                    a.push(m);
                }
            }
            else if (n == rate) {
                a.push(m);
            }
        }

        return getRandomInArray(a);
    }

    /**
     * 生成 [from, to) 的整数再随机打乱。
     * @param from 起始（含）。
     * @param to 结束（不含）。
     * @return 打乱后的数组。
     * @example
     * <listing version="3.0">
     * var ints:Vector.&lt;int&gt; = KyoRandom.getRandomInts(0, 5);
     * </listing>
     */
    public static function getRandomInts(from:int, to:int):Vector.<int> {
        var a:Vector.<int> = new Vector.<int>();
        for (var i:int = from; i < to; i++) {
            a.push(i);
        }
        for (var j:int = a.length - 1; j > 0; j--) {
            var k:int = int(Math.random() * (j + 1));
            var t:int = a[j];
            a[j] = a[k];
            a[k] = t;
        }

        return a;
    }

    /**
     * 原地将数组随机排序。
     * @param array 目标数组。
     * @example
     * <listing version="3.0">
     * KyoRandom.arraySortRandom(list);
     * </listing>
     */
    public static function arraySortRandom(array:Array):void {
        array.sort(function (element1:*, element2:*):int {
            return Math.random() < 0.5 ? -1 : 1;
        });
    }

    /**
     * 随机颜色。
     * @param from 下界。
     * @param to 上界。
     * @return 颜色值。
     * @example
     * <listing version="3.0">
     * var c:uint = KyoRandom.getRandomColor();
     * </listing>
     * @see KyoColor
     */
    public static function getRandomColor(from:uint = KyoColor.BLACK, to:uint = KyoColor.WHITE):uint {
        return from + (to - from) * Math.random();
    }

}
}

