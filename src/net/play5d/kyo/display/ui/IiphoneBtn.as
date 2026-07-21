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
/**
 * iPhone 风格图标列表中的可拖拽按钮约定。
 *
 * <p><code>IphoneIconList</code> 在列表拖拽开始时会对实现本接口的子项调用 <code>onDrag</code>。</p>
 *
 * @see IphoneIconList
 */
public interface IiphoneBtn {
    /**
     * 列表进入拖拽态时回调（如取消按钮自身交互）。
     */
    function onDrag():void;

    /**
     * 销毁按钮占用的资源。
     */
    function destory():void;
}
}
