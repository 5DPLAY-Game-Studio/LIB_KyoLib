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

/**
 * 位图水波纹效果：在源图上按点扰动并位移映射输出。
 *
 * <p>每帧调用 <code>render</code> 并传入扰动点；构造时会做一次空渲染以初始化缓冲。</p>
 *
 * @see #render()
 * @see #strongth
 * @see #destroy()
 */
public class WaterWaveEffect extends Sprite {
    /**
     * @param img 源位图（效果生命周期内由本类持有并在 <code>destroy</code> 时 dispose）。
     * @param scale 显示缩放倍数，默认 1。
     */
    public function WaterWaveEffect(img:BitmapData, scale:int = 1) {
        surface = img;

        imgW = img.width;
        imgH = img.height;
        size = scale;

        buildwave();
    }

    /**
     * 扰动强度（写入扰动像素时相对中心点的偏移），默认 1。
     * @default 1
     */
    public var strongth:Number = 1;
    /** @private */
    private var result:BitmapData;
    /** @private */
    private var result2:BitmapData;
    /** @private */
    private var source:BitmapData;
    /** @private */
    private var buffer:BitmapData;
    /** @private */
    private var output:BitmapData;
    /** @private */
    private var surface:BitmapData;
    /** @private */
    private var bounds:Rectangle;
    /** @private */
    private var origin:Point;
    /** @private */
    private var matrix:Matrix;
    /** @private */
    private var matrix2:Matrix;
    /** @private */
    private var wave:ConvolutionFilter;
    /** @private */
    private var damp:ColorTransform;
    /** @private */
    private var water:DisplacementMapFilter;
    /** @private */
    private var imgW:Number;
    /** @private */
    private var imgH:Number;
    /** @private 显示缩放 */
    private var size:int;

    /**
     * 释放内部缓冲与源图。
     * @example
     * <listing version="3.0">
     * wave.destroy();
     * </listing>
     */
    public function destroy():void {
        result.dispose();
        result2.dispose();
        source.dispose();
        buffer.dispose();
        surface.dispose();
        output.dispose();

        result  = null;
        result2 = null;
        source  = null;
        buffer  = null;
        surface = null;
        output  = null;

        wave  = null;
        damp  = null;
        water = null;
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
            for each(var p:Point in points) {
                var _x:Number = p.x / 1.5 / size;
                var _y:Number = p.y / 1.5 / size;
                source.setPixel(_x + strongth, _y, 16777215);
                source.setPixel(_x - strongth, _y, 16777215);
                source.setPixel(_x, _y + strongth, 16777215);
                source.setPixel(_x, _y - strongth, 16777215);
                source.setPixel(_x, _y, 16777215);
            }
        }

        result.applyFilter(source, bounds, origin, wave);

        result.draw(result, matrix, null, BlendMode.ADD);
        result.draw(buffer, matrix, null, BlendMode.DIFFERENCE);
        result.draw(result, matrix, damp);
        result2.draw(result, matrix2, null, null, null, true);
        output.applyFilter(surface, new Rectangle(0, 0, imgW, imgH), origin, water);
        buffer = source;
        source = result.clone();
    }

    /**
     * @private 创建缓冲、滤镜与显示位图。
     */
    private function buildwave():void {
        result  = new BitmapData(imgW, imgH, false, 128);
        result2 = new BitmapData(imgW, imgH, false, 128);
        source  = new BitmapData(imgW, imgH, false, 128);
        buffer  = new BitmapData(imgW, imgH, false, 128);
        output  = new BitmapData(imgW, imgH, false, 128);
        bounds  = new Rectangle(0, 0, imgW, imgH);
        origin  = new Point();

        matrix    = new Matrix();
        matrix2   = new Matrix();
        matrix2.a = matrix2.d = 2;

        wave           = new ConvolutionFilter(3, 3, [1, 1, 1, 1, 1, 1, 1, 1, 1], 9, 0);
        damp           = new ColorTransform(0, 0, 9.960937E-001, 1, 0, 0, 2, 0);
        water          = new DisplacementMapFilter(result2, origin, 4, 4, 28, 28);
        var _bg:Sprite = new Sprite();
        addChild(_bg);
        _bg.graphics.beginFill(0xFFFFFF, 0);
        _bg.graphics.drawRect(0, 0, imgW, imgH);
        _bg.graphics.endFill();

        var b:Bitmap = new Bitmap(output);
        b.scaleX     = b.scaleY = size;
        addChild(b);

        render();
    }

}
}
