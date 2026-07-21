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
import flash.display.DisplayObject;
import flash.events.IEventDispatcher;

/**
 * 选项卡项约定：可选中态，并提供用于布局的显示对象。
 *
 * @see TabBox
 */
public interface ITab extends IEventDispatcher {
    /**
     * 是否处于选中态。
     */
    function get selected():Boolean;

    /**
     * @private
     */
    function set selected(v:Boolean):void;

    /**
     * 作为子项加入布局的显示对象。
     */
    function get display():DisplayObject;
}
}
