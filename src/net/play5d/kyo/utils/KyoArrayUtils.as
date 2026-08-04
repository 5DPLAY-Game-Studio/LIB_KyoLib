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
/**
 * 数组查找、增删、分组与去重。
 */
public class KyoArrayUtils {
    /**
     * 根据子元素属性查找一个对象
     * @param array
     * @param matchKey
     * @param matchValue
     * @return
     * @example
     * <listing version="3.0">
     * var o:* = KyoArrayUtils.findOneByPortal(list, 'id', 1);
     * </listing>
     */
    public static function findOneByPortal(array:Array, matchKey:*, matchValue:*):* {
        for each(var i:* in array) {
            if (i[matchKey] == matchValue) {
                return i;
            }
        }
        return null;
    }

    /**
     * 根据子元素属性删除对象
     * @param array
     * @param matchKey
     * @param matchValue
     * @example
     * <listing version="3.0">
     * KyoArrayUtils.removeByPortal(list, 'id', 1);
     * </listing>
     */
    public static function removeByPortal(array:Array, matchKey:*, matchValue:*):void {
        for (var i:int; i < array.length; i++) {
            var m:* = array[i];
            if (m[matchKey] == matchValue) {
                array.splice(i, 1);
            }
        }
    }

    /**
     * 根据子元素属性查找所有符合的对象
     * @param array
     * @param matchKey
     * @param matchValue
     * @return
     * @example
     * <listing version="3.0">
     * var a:Array = KyoArrayUtils.findAllByPortal(list, 'type', 'a');
     * </listing>
     */
    public static function findAllByPortal(array:Array, matchKey:*, matchValue:*):* {
        var r:Array = [];
        for each(var i:* in array) {
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
        var i:int = array.indexOf(item);
        return i != -1;
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
        var i:int = array.indexOf(item);
        if (i == -1) {
            array.push(item);
            return true;
        }
        else {
            return false;
        }
    }

    /**
     * 将对象插入到指定的index中
     * @param array
     * @param item 一个或多个对象，多个对象时为Array类型
     * @param index
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
            var ii:int = i + (
                    items.length - 1
            );
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
     * 删除数组中的重复对象。
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
        for each(var i:* in array) {
            a.push(i);
        }
        return a;
    }

    /**
     * 获取属性相同的数据。
     * @param array 源数组。
     * @param key 属性名。
     * @return 属性值重复的项组成的数组。
     * @example
     * <listing version="3.0">
     * var same:Array = KyoArrayUtils.getSamePortalItems(list, 'id');
     * </listing>
     */
    public static function getSamePortalItems(array:Array, key:String):Array {
        var vo:Object = {};
        var vs:Object = {};

        for each(var i:* in array) {
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
            for each(i in array) {
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
     * var g:Object = KyoArrayUtils.groupByPortal(list, 'type');
     * </listing>
     */
    public static function groupByPortal(array:Array, key:String):Object {
        var o:Object = {};
        for each(var i:* in array) {
            var v:* = i[key];
            o[v] ||= [];
            (
                    o[v] as Array
            ).push(i);
        }
        return o;
    }

}
}
