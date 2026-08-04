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

package net.play5d.kyo.stage.effect {
import com.greensock.TweenLite;
import com.greensock.easing.Elastic;

import net.play5d.kyo.stage.IStage;

/**
 * 弹性上下位移的场景淡入 / 淡出效果。
 *
 * @see IStageFadeEffect
 * @see ZoomEffect
 */
public class ElastEffect implements IStageFadeEffect {
    /**
     * @param duration 动画时长（秒）。
     */
    public function ElastEffect(duration:Number = 1) {
        _duration = duration;
    }

    /** @private */
    private var _duration:Number;

    /**
     * 从上方弹入。
     * @param stage 目标场景。
     * @param complete 完成回调（当前实现未调用）。
     * @example
     * <listing version="3.0">
     * new ElastEffect().fadeIn(stage);
     * </listing>
     */
    public function fadeIn(stage:IStage, complete:Function = null):void {
        TweenLite.from(stage.display, _duration, {y: -stage.display.height, ease: Elastic.easeOut});
    }

    /**
     * 向上方弹出离开。
     * @param stage 目标场景。
     * @param complete 完成回调（当前实现未调用）。
     * @example
     * <listing version="3.0">
     * new ElastEffect().fadeOut(stage);
     * </listing>
     */
    public function fadeOut(stage:IStage, complete:Function = null):void {
        TweenLite.to(stage.display, _duration, {y: -stage.display.height, ease: Elastic.easeOut});
    }
}
}
