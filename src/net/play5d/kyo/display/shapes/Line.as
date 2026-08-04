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

package net.play5d.kyo.display.shapes {
import flash.display.Shape;

import net.play5d.kyo.utils.KyoColor;

/**
 * 线段形状：用细矩形模拟线段，可设置旋转角。
 *
 * @example
 * <listing version="3.0">
 * var line:Line = new Line(100, 2, KyoColor.RED, 45);
 * addChild(line);
 * </listing>
 */
public class Line extends Shape {
    /**
     * 绘制一条线段。
     * @param width 线段长度（像素）。
     * @param thinkness 线粗（高度），默认 1。
     * @param color 填充色，默认黑色。
     * @param angel 旋转角度（度），默认 0。
     */
    public function Line(width:Number, thinkness:Number = 1, color:int = KyoColor.BLACK, angel:int = 0) {
        super();
        graphics.beginFill(color, 1);
        graphics.drawRect(0, 0, width, thinkness);
        graphics.endFill();
        this.rotation = angel;
    }
}
}
