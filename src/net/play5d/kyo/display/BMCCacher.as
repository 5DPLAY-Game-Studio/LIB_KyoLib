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

package net.play5d.kyo.display {
/**
 * <code>BitmapMovieClip</code> 帧数组缓存，可限制最大缓存组数。
 *
 * @see BitmapMovieClip
 * @see BitmapMCFrameVO
 * @see #cache()
 * @see #get()
 */
public class BMCCacher {
    /**
     * @param totalAmount 最大缓存组数；为 -1 表示不限制，默认 -1。
     */
    public function BMCCacher(totalAmount:int = -1) {
        _total = totalAmount;
    }

    /** @private 上限；-1 不限 */
    private var _total:int;
    /** @private 当前缓存组数 */
    private var _amount:int;
    /** @private id → 帧数组 */
    private var _cacheObj:Object = {};

    /**
     * 缓存一组帧数据；超出上限时先 <code>clean</code>。
     * @param id 缓存键。
     * @param insarray <code>BitmapMCFrameVO</code> 数组。
     * @example
     * <listing version="3.0">
     * cacher.cache('hero', bmc.insArray);
     * </listing>
     */
    public function cache(id:String, insarray:Array):void {
        _amount++;
        if (_total != -1 && _amount > _total) {
            clean();
        }
        _cacheObj[id] = insarray;
    }

    /**
     * 按键取缓存帧数组。
     * @param id 缓存键。
     * @return 帧数组；无则 <code>undefined</code>。
     * @example
     * <listing version="3.0">
     * var frames:Array = cacher.get('hero');
     * </listing>
     */
    public function get(id:String):Array {
        return _cacheObj[id];
    }

    /**
     * 移除并销毁指定缓存。
     * @param id 缓存键。
     */
    public function remove(id:String):void {
        var a:Array = _cacheObj[id];
        for each(var b:BitmapMCFrameVO in a) {
            b.destroy();
            b = null;
        }
        a = null;
        delete _cacheObj[id];
    }

    /**
     * 清空全部缓存并销毁其中的 <code>BitmapMCFrameVO</code>。
     * @example
     * <listing version="3.0">
     * cacher.clean();
     * </listing>
     */
    public function clean():void {
        for each(var i:Array in _cacheObj) {
            for each(var j:* in i) {
                if (j is BitmapMCFrameVO) {
                    var b:BitmapMCFrameVO = j;
                    b.destroy();
                }
                j = null;
            }
            i = null;
        }
        _cacheObj = {};
        _amount   = 0;
    }

}
}
