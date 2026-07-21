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
import flash.events.IEventDispatcher;

/**
 * 滚动条约定：可启用/禁用，并按内容位置更新滑块。
 *
 * @see KyoScrollBar
 * @see KyoScrollPane
 */
public interface IKyoScrollBar extends IEventDispatcher {
    /**
     * 设置滚动条是否可用。
     * @param v <code>true</code> 为可用。
     */
    function set enabled(v:Boolean):void;

    /**
     * 根据内容滚动位置更新滑块。
     * @param pos 滚动位置（具体含义由实现定义，通常为像素或比例）。
     */
    function update(pos:Number):void;
}
}
