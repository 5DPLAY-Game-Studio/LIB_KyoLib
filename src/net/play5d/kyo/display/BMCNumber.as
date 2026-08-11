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
import flash.display.DisplayObject;
import flash.display.MovieClip;

/**
 * 位图影片数字：每位为 <code>BitmapMovieClip</code>，可由 MC 类绘制或复用帧数组。
 *
 * @see MCNumber
 * @see BitmapMovieClip
 * @example
 * <listing version="3.0">
 * var num:BMCNumber = new BMCNumber(DigitMC, 12);
 * addChild(num);
 * </listing>
 */
public class BMCNumber extends MCNumber {
    /**
     * 构造位图影片数字。
     * @param mc MovieClip 类，或已有 <code>BitmapMCFrameVO</code> 帧数组。
     * @param number 初始数值。
     * @param startFrame 数字起始帧，默认 1。
     * @param mcWidth 每位宽度；-1 为自动，默认 -1。
     */
    public function BMCNumber(mc:Object, number:uint, startFrame:int = 1, mcWidth:Number = -1) {
        var mcClass:Class;
        if (mc is Class) {
            mcClass = mc as Class;
        }
        if (mc is Array) {
            _insArray = mc as Array;
        }

        super(mcClass, number, startFrame, mcWidth);
    }

    /** @private 复用的帧数组 */
    [ArrayElementType('net.play5d.kyo.display.BitmapMCFrameVO')]
    private var _insArray:Array;

    /**
     * @private 创建位图影片并跳到对应数字帧。
     */
    protected override function createNum(i:int):DisplayObject {
        var bmc:BitmapMovieClip = new BitmapMovieClip(false);
        if (_insArray) {
            bmc.insArray = _insArray;
        }
        else {
            bmc.draw(new _mc());
        }

        bmc.gotoAndStop(startFrame + i);
        addChild(bmc);
        _mcs.push(bmc);

        return bmc;
    }
}
}
