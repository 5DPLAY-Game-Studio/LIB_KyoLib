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

package net.play5d.kyo.display.ui {
import flash.display.Sprite;
import flash.events.Event;

/**
 * UI 盒基类：持有子项实例数组或 <code>KyoRepeater</code>，由子类实现布局构建。
 *
 * @see TabBox
 * @see KyoRepeater
 * @see #instances
 * @see #repeater
 */
public class BaseBox extends Sprite {
    /**
     * 构造空盒。
     */
    public function BaseBox() {
    }

    /**
     * 子项水平间距。
     * @default NaN
     */
    public var gapX:Number;
    /**
     * 子项垂直间距。
     * @default NaN
     */
    public var gapY:Number;
    /** @private 子项实例列表 */
    protected var _instances:Array;

    /**
     * 子项实例数组；赋值时调用 <code>build</code>。
     * @return 实例数组。
     * @default null
     */
    public final function get instances():Array {
        return _instances;
    }

    /** @private */
    public final function set instances(v:Array):void {
        _instances = v;
        build();
    }

    /** @private */
    private var _repeater:KyoRepeater;

    /**
     * 数据重复器；赋值时调用 <code>buildByRepeater</code>。
     * @return <code>KyoRepeater</code> 实例。
     * @default null
     */
    public final function get repeater():KyoRepeater {
        return _repeater;
    }

    /** @private */
    public final function set repeater(value:KyoRepeater):void {
        _repeater = value;
        buildByRepeater();
    }

    /**
     * @private 根据 <code>_instances</code> 构建布局；子类覆盖。
     */
    protected function build():void {
    }

    /**
     * @private 根据 <code>_repeater</code> 构建布局；子类覆盖。
     */
    protected function buildByRepeater():void {
    }

    /**
     * 清空并置空 <code>_instances</code>（可作事件监听器）。
     * @param e 可选事件参数（未使用）。
     * @example
     * <listing version="3.0">
     * box.removeAll(null);
     * </listing>
     */
    public function removeAll(e:Event = null):void {
        for (var i:String in _instances) {
            delete _instances[i];
        }

        _instances = null;
    }
}
}