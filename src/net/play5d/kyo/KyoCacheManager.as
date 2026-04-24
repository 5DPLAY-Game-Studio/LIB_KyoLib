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

package net.play5d.kyo {
import flash.display.BitmapData;

/**
 * 缓存管理器类
 */
public class KyoCacheManager {

    // 缓存对象的数量计数器
    public static var count:int = 0;
    // 缓存对象字典，键为 ID 字符串，值为任意类型对象
    private static var _cacheObjs:Object = {};

    /**
     * 根据ID缓存对象
     *
     * @param obj 要缓存的对象
     * @param id 缓存对象的ID字符串
     */
    public static function cacheById(obj:*, id:String):void {
        // 增加缓存对象数量计数器
        count++;
        // 将对象存入缓存字典，以ID为键
        _cacheObjs[id] = obj;
    }

    /**
     * 根据ID获取缓存对象
     *
     * @param id 缓存对象的ID字符串
     * @return 缓存对象，若不存在则返回null
     */
    public static function getById(id:String):* {
        var obj:* = _cacheObjs[id];
        if (!obj || obj == undefined) {
            return null;
        }

        return obj;
    }

    /**
     * 清除所有缓存项
     */
    public static function clear():void {
        // 遍历并清除
        for each(var item:* in _cacheObjs) {
            clearItem(item);
        }

        // 重置
        count      = 0;
        _cacheObjs = {};
    }

    /**
     * 清除单个缓存项
     *
     * @param item 要被清理的项目
     */
    private static function clearItem(item:*):void {
        // 若对象是 BitmapData 类型，调用 dispose() 释放内存
        if (item is BitmapData) {
            (item as BitmapData).dispose();
        }
        // 若对象是Array类型，递归清除数组中的每个元素
        else if (item is Array) {
            for each(var k:* in (item as Array)) {
                clearItem(k);
            }
        }

        item = null;
    }


}
}
