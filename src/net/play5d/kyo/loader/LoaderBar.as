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

package net.play5d.kyo.loader {
import flash.display.Shape;
import flash.display.Sprite;
import flash.geom.Point;

import net.play5d.kyo.utils.KyoColor;

/**
 * 简单矩形进度条（底框 + 可缩放前景条）。
 *
 * @see #initialize()
 * @see #update()
 * @see PreLoader
 */
public class LoaderBar extends Sprite {
    /**
     * @param width 条宽。
     * @param height 条高。
     */
    public function LoaderBar(width:Number = 500, height:Number = 10) {
        super();
        size = new Point(width, height);

        initialize();
    }

    /**
     * 前景填充色。
     * @default KyoColor.RED
     */
    public var color:uint = KyoColor.RED;
    /**
     * 边框颜色。
     * @default 0x426F00
     */
    public var lineColor:uint = 0x426F00;
    /**
     * 边框线宽。
     * @default 2
     */
    public var thickness:uint = 2;
    /**
     * 背景填充色。
     * @default KyoColor.BLACK
     */
    public var backColor:uint = KyoColor.BLACK;
    /**
     * 尺寸（x=宽，y=高）。
     */
    public var size:Point;
    /** @private */
    private var _bar:Shape;

    /**
     * 按当前颜色与尺寸重绘底框与进度条。
     * @example
     * <listing version="3.0">
     * bar.color = KyoColor.LIME;
     * bar.initialize();
     * </listing>
     */
    public function initialize():void {
        graphics.clear();
        graphics.lineStyle(thickness, lineColor);
        graphics.beginFill(backColor, 1);
        graphics.drawRect(0, -1, size.x, size.y + 1);
        graphics.endFill();

        _bar ||= new Shape();
        _bar.graphics.clear();
        _bar.graphics.beginFill(color, 1);
        _bar.graphics.drawRect(0, 0, size.x, size.y);
        _bar.graphics.endFill();

        addChild(_bar);
    }

    /**
     * 更新进度（通过前景 <code>scaleX</code>）。
     * @param p 0~1。
     * @example
     * <listing version="3.0">
     * bar.update(0.5);
     * </listing>
     */
    public function update(p:Number):void {
        _bar.scaleX = p;
    }
}
}
