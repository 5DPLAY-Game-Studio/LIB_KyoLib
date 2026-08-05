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
 * 按钮组：在一组 <code>IKyoButton</code> 中互斥设置焦点。
 *
 * @see IKyoButton
 * @see #focus()
 */
public class KyoBtnGroup {
    /**
     * @param btns 按钮集合（可遍历的 <code>Object</code> / 数组等）。
     */
    public function KyoBtnGroup(btns:Object) {
        _btns = btns;
    }

    /** @private */
    private var _btns:Object;

    /**
     * 将指定按钮设为焦点，其余按钮取消焦点。
     * @param btn 要聚焦的按钮。
     * @example
     * <listing version="3.0">
     * group.focus(btnA);
     * </listing>
     */
    public function focus(btn:IKyoButton):void {
        for each (var i:IKyoButton in _btns) {
            if (i == btn) {
                continue;
            }
            i.focus = false;
        }

        btn.focus = true;
    }

}
}

