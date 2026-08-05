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
 * 数组查找、增删、分组与去重。
 *
 * @see #findOneByProperty()
 * @see #groupByProperty()
 */
public class KyoArrayUtils {
    /**
     * 按子元素属性查找第一个匹配项。
     * @param array 源数组。
     * @param matchKey 属性名。
     * @param matchValue 属性值。
     * @return 匹配项；未找到返回 <code>null</code>。
     * @example
     * <listing version="3.0">
     * var o:* = KyoArrayUtils.findOneByProperty(list, 'id', 1);
     * </listing>
     */
    public static function findOneByProperty(array:Array, matchKey:*, matchValue:*):* {
        for each (var i:* in array) {
            if (i[matchKey] == matchValue) {
                return i;
            }
        }

        return null;
    }

    /**
     * 按子元素属性删除所有匹配项。
     * @param array 源数组。
     * @param matchKey 属性名。
     * @param matchValue 属性值。
     * @example
     * <listing version="3.0">
     * KyoArrayUtils.removeByProperty(list, 'id', 1);
     * </listing>
     */
    public static function removeByProperty(array:Array, matchKey:*, matchValue:*):void {
        for (var i:int = array.length - 1; i >= 0; i--) {
            if (array[i][matchKey] == matchValue) {
                array.splice(i, 1);
            }
        }
    }

    /**
     * 按子元素属性查找全部匹配项。
     * @param array 源数组。
     * @param matchKey 属性名。
     * @param matchValue 属性值。
     * @return 匹配项数组。
     * @example
     * <listing version="3.0">
     * var a:Array = KyoArrayUtils.findAllByProperty(list, 'type', 'a');
     * </listing>
     */
    public static function findAllByProperty(array:Array, matchKey:*, matchValue:*):Array {
        var r:Array = [];
        for each (var i:* in array) {
            if (i[matchKey] == matchValue) {
                r.push(i);
            }
        }

        return r;
    }

    /**
     * 数组中是否存在对象。
     * @param array 目标数组。
     * @param item 待查找项。
     * @return 是否存在。
     * @example
     * <listing version="3.0">
     * KyoArrayUtils.hasItem(a, 1);
     * </listing>
     */
    public static function hasItem(array:Array, item:*):Boolean {
        return array.indexOf(item) != -1;
    }

    /**
     * 插入不存在的对象到数组中。
     * @param array 目标数组。
     * @param item 待插入项。
     * @return 是否新插入。
     * @example
     * <listing version="3.0">
     * KyoArrayUtils.pushIfAbsent(a, item);
     * </listing>
     */
    public static function pushIfAbsent(array:Array, item:*):Boolean {
        if (item == null) {
            return false;
        }
        if (array.indexOf(item) != -1) {
            return false;
        }

        array.push(item);

        return true;
    }

    /**
     * 将对象插入到指定下标。
     * @param array 目标数组。
     * @param item 一个或多个对象；多个时为 <code>Array</code>。
     * @param index 插入下标。
     * @example
     * <listing version="3.0">
     * KyoArrayUtils.pushAt(a, item, 0);
     * </listing>
     */
    public static function pushAt(array:Array, item:*, index:int):void {
        var items:Array;
        if (item is Array) {
            items = item as Array;
        }
        else {
            items = [item];
        }

        for (var i:int = array.length; i > index; i--) {
            var ii:int = i + (items.length - 1);
            array[ii]  = array[i - 1];
        }

        for (var j:int = 0; j < items.length; j++) {
            array[index + j] = items[j];
        }
    }

    /**
     * 从数组中删除对象。
     * @param array 目标数组或类数组。
     * @param item 待删除项。
     * @example
     * <listing version="3.0">
     * KyoArrayUtils.removeItem(a, item);
     * </listing>
     */
    public static function removeItem(array:Object, item:*):void {
        var i:int = array.indexOf(item);
        if (i != -1) {
            array.splice(i, 1);
        }
    }

    /**
     * 删除数组中的重复对象（保留首次出现）。
     * @param array 目标数组或类数组。
     * @example
     * <listing version="3.0">
     * KyoArrayUtils.deleteDuplicates(a);
     * </listing>
     */
    public static function deleteDuplicates(array:Object):void {
        var ba:Object = array.concat();

        array.splice(0, array.length);

        for (var i:int = 0; i < ba.length; i++) {
            var o:Object = ba[i];
            if (array.indexOf(o) == -1) {
                array.push(o);
            }
        }
    }

    /**
     * 统计数组中某项出现次数。
     * @param array 数组或类数组。
     * @param item 目标项。
     * @return 次数。
     * @example
     * <listing version="3.0">
     * KyoArrayUtils.countItem(a, 1);
     * </listing>
     */
    public static function countItem(array:Object, item:*):int {
        var n:int;
        for (var i:int = 0; i < array.length; i++) {
            if (array[i] == item) {
                n++;
            }
        }

        return n;
    }

    /**
     * 将数组元素浅拷贝到新数组（重排下标）。
     * @param array 源数组。
     * @return 新数组。
     * @example
     * <listing version="3.0">
     * var a:Array = KyoArrayUtils.fixIds(src);
     * </listing>
     */
    public static function fixIds(array:Array):Array {
        var a:Array = [];
        for each (var i:* in array) {
            a.push(i);
        }

        return a;
    }

    /**
     * 获取属性值重复的项。
     * @param array 源数组。
     * @param key 属性名。
     * @return 属性值重复的项组成的数组。
     * @example
     * <listing version="3.0">
     * var same:Array = KyoArrayUtils.getSamePropertyItems(list, 'id');
     * </listing>
     */
    public static function getSamePropertyItems(array:Array, key:String):Array {
        var vo:Object = {};
        var vs:Object = {};

        for each (var i:* in array) {
            var v:* = i[key];
            if (vo[v]) {
                vs[v] = 1;
            }
            else {
                vo[v] = 1;
            }
        }

        var r:Array = [];
        for (var j:String in vs) {
            for each (i in array) {
                if (i[key] == j) {
                    r.push(i);
                }
            }
        }

        return r;
    }

    /**
     * 按属性值分组。
     * @param array 源数组。
     * @param key 属性名。
     * @return key → 同组元素数组。
     * @example
     * <listing version="3.0">
     * var g:Object = KyoArrayUtils.groupByProperty(list, 'type');
     * </listing>
     */
    public static function groupByProperty(array:Array, key:String):Object {
        var o:Object = {};
        for each (var i:* in array) {
            var v:* = i[key];
            o[v] ||= [];
            (o[v] as Array).push(i);
        }

        return o;
    }

}
}

