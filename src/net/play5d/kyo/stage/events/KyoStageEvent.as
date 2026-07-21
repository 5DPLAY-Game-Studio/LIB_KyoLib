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

package net.play5d.kyo.stage.events {
import flash.events.Event;

import net.play5d.kyo.stage.IStage;

/**
 * 场景控制器相关事件。
 *
 * @see net.play5d.kyo.stage.KyoStageCtrl
 * @see #CHANGE_STATE
 * @see #stage
 */
public class KyoStageEvent extends Event {
    /**
     * <code>CHANGE_STATE</code> 事件的 <code>type</code> 属性值。
     * @eventType CHANGE_STATE
     */
    public static const CHANGE_STATE:String = 'CHANGE_STATE';

    /**
     * @param type 事件类型。
     * @param stage 相关场景。
     * @param bubbles 是否冒泡。
     * @param cancelable 是否可取消。
     */
    public function KyoStageEvent(type:String, stage:IStage, bubbles:Boolean = false, cancelable:Boolean = false) {
        super(type, bubbles, cancelable);
        this.stage = stage;
    }

    /**
     * 事件关联的场景。
     */
    public var stage:IStage;
}
}
