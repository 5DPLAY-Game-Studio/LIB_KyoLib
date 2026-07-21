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
 * 按 ID 缓存任意对象；清理时对 <code>BitmapData</code> 调用 dispose，并递归清理数组元素。
 *
 * @see #cacheById()
 * @see #getById()
 * @see #clear()
 */
public class KyoCacheManager {
    /**
     * 已缓存条目计数（每次 <code>cacheById</code> 递增；覆盖同 ID 仍会加一）。
     * @default 0
     */
    public static var count:int = 0;
    /** @private id → 缓存对象 */
    private static var _cacheObjs:Object = {};

    /**
     * 按 ID 写入缓存。
     * @param obj 要缓存的对象。
     * @param id 缓存键。
     * @example
     * <listing version="3.0">
     * KyoCacheManager.cacheById(bd, 'hero');
     * </listing>
     */
    public static function cacheById(obj:*, id:String):void {
        count++;
        _cacheObjs[id] = obj;
    }

    /**
     * 按 ID 取出缓存。
     * @param id 缓存键。
     * @return 对象；不存在则为 <code>null</code>。
     * @example
     * <listing version="3.0">
     * var o:* = KyoCacheManager.getById('hero');
     * </listing>
     */
    public static function getById(id:String):* {
        var obj:* = _cacheObjs[id];
        if (!obj || obj == undefined) {
            return null;
        }

        return obj;
    }

    /**
     * 清除全部缓存并重置计数。
     * @example
     * <listing version="3.0">
     * KyoCacheManager.clear();
     * </listing>
     */
    public static function clear():void {
        for each(var item:* in _cacheObjs) {
            clearItem(item);
        }

        count      = 0;
        _cacheObjs = {};
    }

    /**
     * @private 释放 BitmapData 或递归清理数组元素。
     */
    private static function clearItem(item:*):void {
        if (item is BitmapData) {
            (item as BitmapData).dispose();
        }
        else if (item is Array) {
            for each(var k:* in (item as Array)) {
                clearItem(k);
            }
        }

        item = null;
    }

}
}
