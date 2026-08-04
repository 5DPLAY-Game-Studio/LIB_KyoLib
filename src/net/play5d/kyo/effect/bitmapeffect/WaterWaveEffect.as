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

package net.play5d.kyo.effect.bitmapeffect {
import flash.display.*;
import flash.filters.ConvolutionFilter;
import flash.filters.DisplacementMapFilter;
import flash.geom.*;

import net.play5d.kyo.utils.KyoColor;

/**
 * 位图水波纹效果：在源图上按点扰动并位移映射输出。
 *
 * <p>每帧调用 <code>render</code> 并传入扰动点；构造时会做一次空渲染以初始化缓冲。</p>
 *
 * @see #render()
 * @see #strength
 * @see #destroy()
 */
public class WaterWaveEffect extends Sprite {
    /**
     * @param img 源位图（效果生命周期内由本类持有并在 <code>destroy</code> 时 dispose）。
     * @param scale 显示缩放倍数，默认 1。
     */
    public function WaterWaveEffect(img:BitmapData, scale:int = 1) {
        _surface = img;
        _imgW    = img.width;
        _imgH    = img.height;
        _scale   = scale;

        buildWave();
    }

    /**
     * 扰动强度（写入扰动像素时相对中心点的偏移），默认 1。
     * @default 1
     */
    public var strength:Number = 1;
    /** @private */
    private var _result:BitmapData;
    /** @private */
    private var _result2:BitmapData;
    /** @private */
    private var _source:BitmapData;
    /** @private */
    private var _buffer:BitmapData;
    /** @private */
    private var _output:BitmapData;
    /** @private */
    private var _surface:BitmapData;
    /** @private */
    private var _bounds:Rectangle;
    /** @private */
    private var _origin:Point;
    /** @private */
    private var _matrix:Matrix;
    /** @private */
    private var _matrix2:Matrix;
    /** @private */
    private var _wave:ConvolutionFilter;
    /** @private */
    private var _damp:ColorTransform;
    /** @private */
    private var _water:DisplacementMapFilter;
    /** @private */
    private var _imgW:Number;
    /** @private */
    private var _imgH:Number;
    /** @private 显示缩放 */
    private var _scale:int;

    /**
     * 释放内部缓冲与源图。
     * @example
     * <listing version="3.0">
     * wave.destroy();
     * </listing>
     */
    public function destroy():void {
        _result.dispose();
        _result2.dispose();
        _source.dispose();
        _buffer.dispose();
        _surface.dispose();
        _output.dispose();

        _result  = null;
        _result2 = null;
        _source  = null;
        _buffer  = null;
        _surface = null;
        _output  = null;

        _wave  = null;
        _damp  = null;
        _water = null;
    }

    /**
     * 推进一帧水波演算；可选在指定点写入扰动。
     * @param points 扰动坐标数组（元素为 <code>Point</code>）；为 <code>null</code> 时仅做传播衰减。
     * @example
     * <listing version="3.0">
     * wave.render([new Point(mouseX, mouseY)]);
     * </listing>
     */
    public function render(points:Array = null):void {
        if (points) {
            for each (var p:Point in points) {
                var px:Number = p.x / 1.5 / _scale;
                var py:Number = p.y / 1.5 / _scale;

                _source.setPixel(px + strength, py, KyoColor.WHITE);
                _source.setPixel(px - strength, py, KyoColor.WHITE);
                _source.setPixel(px, py + strength, KyoColor.WHITE);
                _source.setPixel(px, py - strength, KyoColor.WHITE);
                _source.setPixel(px, py, KyoColor.WHITE);
            }
        }

        _result.applyFilter(_source, _bounds, _origin, _wave);
        _result.draw(_result, _matrix, null, BlendMode.ADD);
        _result.draw(_buffer, _matrix, null, BlendMode.DIFFERENCE);
        _result.draw(_result, _matrix, _damp);
        _result2.draw(_result, _matrix2, null, null, null, true);
        _output.applyFilter(_surface, new Rectangle(0, 0, _imgW, _imgH), _origin, _water);

        _buffer = _source;
        _source = _result.clone();
    }

    /**
     * @private 创建缓冲、滤镜与显示位图。
     */
    private function buildWave():void {
        _result  = new BitmapData(_imgW, _imgH, false, 128);
        _result2 = new BitmapData(_imgW, _imgH, false, 128);
        _source  = new BitmapData(_imgW, _imgH, false, 128);
        _buffer  = new BitmapData(_imgW, _imgH, false, 128);
        _output  = new BitmapData(_imgW, _imgH, false, 128);
        _bounds  = new Rectangle(0, 0, _imgW, _imgH);
        _origin  = new Point();

        _matrix    = new Matrix();
        _matrix2   = new Matrix();
        _matrix2.a = _matrix2.d = 2;

        _wave  = new ConvolutionFilter(3, 3, [1, 1, 1, 1, 1, 1, 1, 1, 1], 9, 0);
        _damp  = new ColorTransform(0, 0, 9.960937E-001, 1, 0, 0, 2, 0);
        _water = new DisplacementMapFilter(_result2, _origin, 4, 4, 28, 28);

        var bg:Sprite = new Sprite();
        addChild(bg);
        bg.graphics.beginFill(KyoColor.WHITE, 0);
        bg.graphics.drawRect(0, 0, _imgW, _imgH);
        bg.graphics.endFill();

        var b:Bitmap = new Bitmap(_output);
        b.scaleX     = b.scaleY = _scale;
        addChild(b);

        render();
    }
}
}
