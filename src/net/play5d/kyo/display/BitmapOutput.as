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
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.geom.Matrix;

import net.play5d.kyo.utils.KyoColor;

/**
 * 将显示对象按固定尺寸绘制到自身 <code>bitmapData</code> 的位图输出。
 *
 * @see #render()
 * @see #destroy()
 */
public class BitmapOutput extends Bitmap {
    /**
     * @param source 绘制源。
     * @param width 输出宽。
     * @param height 输出高。
     * @param transparent 是否透明，默认 <code>false</code>。
     * @param fillColor 填充色，默认 <code>KyoColor.BLACK</code>。
     * @param pixelSnapping 像素对齐，默认 <code>'auto'</code>。
     * @param smoothing 是否平滑，默认 <code>false</code>。
     */
    public function BitmapOutput(
        source       :DisplayObject,
        width        :int,
        height       :int,
        transparent  :Boolean = false,
        fillColor    :int = KyoColor.BLACK,
        pixelSnapping:String = 'auto',
        smoothing    :Boolean = false
    ) {
        super(null, pixelSnapping, smoothing);

        _source      = source;
        _width       = width;
        _height      = height;
        _transparent = transparent;
        _fillColor   = fillColor;
    }

    /** @private */
    private var _source:DisplayObject;
    /** @private */
    private var _width:int;
    /** @private */
    private var _height:int;
    /** @private */
    private var _transparent:Boolean;
    /** @private */
    private var _fillColor:int;

    /**
     * 按源当前缩放重新绘制到位图。
     * @example
     * <listing version="3.0">
     * output.render();
     * </listing>
     */
    public function render():void {
        bitmapData = new BitmapData(_width, _height, _transparent, _fillColor);

        var m:Matrix = new Matrix(_source.scaleX, 0, 0, _source.scaleY);
        bitmapData.draw(_source, m);
    }

    /**
     * 断开源引用并释放位图。
     * @example
     * <listing version="3.0">
     * output.destroy();
     * </listing>
     */
    public function destroy():void {
        _source = null;

        bitmapData.dispose();
        bitmapData = null;
    }
}
}
