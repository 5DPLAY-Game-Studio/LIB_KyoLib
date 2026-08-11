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
import flash.events.Event;

/**
 * Kyo UI 控件事件（如滚动条拖拽更新）。
 *
 * @see KyoScrollBar
 * @see #UPDATE
 * @see #params
 */
public class KyoUIEvent extends Event {
    /**
     * <code>UPDATE</code> 事件的 <code>type</code> 属性值。
     * @eventType event-update
     */
    public static const UPDATE:String = 'event-update';

    /**
     * 构造 UI 控件事件。
     * @param type 事件类型。
     * @param params 附加参数（如滚动比例 <code>Point</code>），可选。
     * @example
     * <listing version="3.0">
     * dispatchEvent(new KyoUIEvent(KyoUIEvent.UPDATE, {ratio: 0.5}));
     * </listing>
     */
    public function KyoUIEvent(type:String, params:Object = null) {
        super(type, false, false);
        this.params = params;
    }

    /**
     * 事件附带数据。
     * @default null
     */
    public var params:Object;
}
}
