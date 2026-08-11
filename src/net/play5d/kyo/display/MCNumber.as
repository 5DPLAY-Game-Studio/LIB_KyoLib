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
import flash.display.Sprite;

/**
 * 以 MovieClip 跳帧方式显示数字（每位一个 MC 实例）。
 *
 * @see BMCNumber
 * @see #number
 * @example
 * <listing version="3.0">
 * var num:MCNumber = new MCNumber(DigitMC, 7, 1, -1, 2);
 * addChild(num);
 * num.number = 42;
 * </listing>
 */
public class MCNumber extends Sprite {
    /**
     * 构造数字显示。
     * @param mc MovieClip 导出类（含数字帧）。
     * @param number 初始数值。
     * @param startFrame 数字 0 对应的起始帧，默认 1。
     * @param mcWidth 每位宽度；为 -1 时用实例实际宽度，默认 -1。
     * @param bits 最小位数（不足补 0），默认 0 表示不补。
     */
    public function MCNumber(mc:Class, number:uint, startFrame:int = 1, mcWidth:Number = -1, bits:uint = 0) {
        _mc             = mc;
        _bits           = bits;
        this.startFrame = startFrame;
        this.mcWidth    = mcWidth;
        this.number     = number;
    }

    /**
     * 每位固定宽度；为 -1 时用显示对象宽度。
     * @default -1
     */
    public var mcWidth:Number = -1;
    /**
     * 数字 0 对应的起始帧。
     */
    public var startFrame:int;
    /** @private MC 类 */
    protected var _mc:Class;
    /** @private 当前位显示对象列表 */
    protected var _mcs:Vector.<DisplayObject> = new Vector.<DisplayObject>();
    /** @private 最小位数 */
    protected var _bits:uint;
    /** @private */
    protected var _number:uint;

    /**
     * 当前显示的数值。
     * @return 无符号整数。
     * @example
     * <listing version="3.0">
     * num.number; // 42
     * </listing>
     */
    public function get number():uint {
        return _number;
    }

    /** @private */
    public function set number(v:uint):void {
        _number = v;

        for each (var m:DisplayObject in _mcs) {
            removeChild(m);
        }
        _mcs.length = 0;

        var numStr:String = v.toString();
        while (numStr.length < _bits) {
            numStr = '0' + numStr;
        }

        var xx:Number = 0;
        for (var i:int; i < numStr.length; i++) {
            var digit:DisplayObject = createNum(int(numStr.charAt(i)));
            digit.x                 = xx;
            xx += mcWidth == -1 ? digit.width : mcWidth;
        }
    }

    /**
     * @private 创建并加入一位数字显示对象。
     * @param i 数字 0–9。
     * @return 数字 MC。
     */
    protected function createNum(i:int):DisplayObject {
        var mc:MovieClip = new _mc();
        mc.gotoAndStop(startFrame + i);

        addChild(mc);
        _mcs.push(mc);

        return mc;
    }
}
}
