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
import flash.display.BitmapData;
import flash.display.BlendMode;
import flash.display.GradientType;
import flash.display.Graphics;
import flash.display.Shape;

/**
 * 扇形与环形绘制工具。
 *
 * @see #drawRing()
 * @see #drawSector()
 */
public class KyoDrawUtils {
    /** @private 复用绘图 Shape */
    private static var _drawShape:Shape;

    /**
     * 绘制空心圆环扇形到透明 <code>BitmapData</code>。
     * @param width 环宽。
     * @param radius 外半径。
     * @param angle 扇形角度。
     * @param color 填充色或渐变色数组。
     * @param alpha 透明度。
     * @return 位图。
     * @example
     * <listing version="3.0">
     * var bd:BitmapData = KyoDrawUtils.drawRing(10, 50, 90);
     * </listing>
     */
    public static function drawRing(
            width:Number, radius:Number, angle:int, color:Object = 0xffff00, alpha:Number = 1):BitmapData {

        var bd:BitmapData = new BitmapData(radius * 2, radius * 2, true, 0);

        if (!_drawShape) {
            _drawShape = new Shape();
        }
        drawSector(_drawShape.graphics, radius, radius, radius, angle, -90, color, alpha);
        bd.draw(_drawShape);
        _drawShape.graphics.clear();

        _drawShape.graphics.beginFill(0xff0000, 1);
        _drawShape.graphics.drawCircle(radius, radius, radius - width);
        _drawShape.graphics.endFill();

        bd.draw(_drawShape, null, null, BlendMode.ERASE);
        _drawShape.graphics.clear();

        return bd;
    }

    /**
     * 在指定 <code>Graphics</code> 上绘制扇形。
     * @param graphics 目标画笔。
     * @param x 圆心 x。
     * @param y 圆心 y。
     * @param r 半径。
     * @param angle 角度（绝对值超过 360 按 360）。
     * @param startFrom 起始角度（度）。
     * @param color 单色 <code>uint</code> 或渐变色 <code>Array</code>。
     * @param alpha 透明度。
     * @example
     * <listing version="3.0">
     * KyoDrawUtils.drawSector(g, 100, 100, 50, 90, 0, 0xff0000);
     * </listing>
     */
    public static function drawSector(
            graphics:Graphics, x:Number = 200, y:Number = 200, r:Number = 100, angle:Number = 60, startFrom:Number = 0,
            color:Object = 0xFFFFFF, alpha:Number = 1
    ):void {
        graphics.clear();
        if (color is Array) {
            var alphaArr:Array = [];
            for (var j:int; j < color.length; j++) {
                alphaArr.push(alpha);
            }
            graphics.beginGradientFill(GradientType.LINEAR, color as Array, alphaArr, [128, 255]);
        }
        else {
            graphics.beginFill(color as uint, alpha);
        }

        angle = (Math.abs(angle) > 360) ? 360 : angle;

        var n:int         = Math.ceil(Math.abs(angle) / 45);
        var angleA:Number = angle / n;

        angleA    = angleA * Math.PI / 180;
        startFrom = startFrom * Math.PI / 180;

        graphics.moveTo(x + r * Math.cos(startFrom), y + r * Math.sin(startFrom));

        var i:int;
        var angleMid:Number, bx:Number, by:Number, cx:Number, cy:Number;

        for (i = 1; i <= n; i++) {
            startFrom += angleA;
            angleMid = startFrom - angleA / 2;
            bx       = x + r / Math.cos(angleA / 2) * Math.cos(angleMid);
            by       = y + r / Math.cos(angleA / 2) * Math.sin(angleMid);
            cx       = x + r * Math.cos(startFrom);
            cy       = y + r * Math.sin(startFrom);
            graphics.curveTo(bx, by, cx, cy);
        }

        if (angle != 360) {
            graphics.lineTo(x, y);
        }
        graphics.endFill();
    }

}
}
