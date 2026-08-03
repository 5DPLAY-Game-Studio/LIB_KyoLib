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
import flash.display.BitmapData;
import flash.geom.Rectangle;
import flash.utils.Dictionary;

/**
 * 临时 <code>BitmapData</code> 对象池。
 *
 * <p>按宽高与透明通道分桶复用，减轻绘制时的分配与 GC 压力。
 * 进入缓存长期持有的位图请用 <code>new BitmapData</code>，勿从本池取出后永久占用。</p>
 *
 * @example
 * <listing version="3.0">
 * var bd:BitmapData = BitmapDataPool.I.acquire(64, 64, true, 0);
 * // ... draw ...
 * BitmapDataPool.I.release(bd);
 * </listing>
 */
public class BitmapDataPool {

    /** @private */
    private static var _i:BitmapDataPool;

    /**
     * 单例。
     * @return 单例实例。
     */
    public static function get I():BitmapDataPool {
        if (!_i) {
            _i = new BitmapDataPool();
        }
        return _i;
    }

    /**
     * 构造函数（通常通过 <code>I</code> 使用）。
     */
    public function BitmapDataPool() {
    }

    /** @private 每桶最大缓存张数 */
    private static const MAX_PER_BUCKET:int = 8;

    /** @private */
    private var _buckets:Dictionary = new Dictionary();

    /**
     * 取得指定尺寸的位图；池中无可用实例时新建。
     *
     * @param width 宽度（像素）。
     * @param height 高度（像素）。
     * @param transparent 是否透明。
     * @param fillColor 填充色。
     * @return 可绘制的 <code>BitmapData</code>；宽或高非法时为 <code>null</code>。
     */
    public function acquire(
            width:int, height:int, transparent:Boolean = true, fillColor:uint = 0
    ):BitmapData {
        if (width < 1 || height < 1) {
            return null;
        }

        var key:String               = bucketKey(width, height, transparent);
        var list:Vector.<BitmapData> = _buckets[key] as Vector.<BitmapData>;
        var bd:BitmapData;
        if (list && list.length > 0) {
            bd = list.pop();
            bd.fillRect(new Rectangle(0, 0, bd.width, bd.height), fillColor);
            return bd;
        }
        return new BitmapData(width, height, transparent, fillColor);
    }

    /**
     * 归还位图到池；桶已满则 <code>dispose</code>。
     *
     * @param bd 由 <code>acquire</code> 取得或同尺寸的临时位图。
     */
    public function release(bd:BitmapData):void {
        if (!bd) {
            return;
        }
        try {
            var key:String               = bucketKey(bd.width, bd.height, bd.transparent);
            var list:Vector.<BitmapData> = _buckets[key] as Vector.<BitmapData>;
            if (!list) {
                list          = new Vector.<BitmapData>();
                _buckets[key] = list;
            }
            if (list.length < MAX_PER_BUCKET) {
                list.push(bd);
                return;
            }
        }
        catch (e:Error) {
        }
        try {
            bd.dispose();
        }
        catch (e2:Error) {
        }
    }

    /**
     * 清空并释放池内全部位图。
     */
    public function clear():void {
        for each(var list:Vector.<BitmapData> in _buckets) {
            if (!list) {
                continue;
            }
            for each(var bd:BitmapData in list) {
                try {
                    bd.dispose();
                }
                catch (e:Error) {
                }
            }
            list.length = 0;
        }
        _buckets = new Dictionary();
    }

    /** @private */
    private function bucketKey(width:int, height:int, transparent:Boolean):String {
        return width + 'x' + height + (transparent ? 't' : 'o');
    }

}
}
