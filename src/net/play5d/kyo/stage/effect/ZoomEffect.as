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
import com.greensock.easing.Back;

import flash.display.DisplayObject;
import flash.geom.Point;

import net.play5d.kyo.stage.IStage;

/**
 * 缩放弹出 / 缩回的场景层效果。
 *
 * @see IStageFadeEffect
 * @see ElasticEffect
 */
public class ZoomEffect implements IStageFadeEffect {
    /**
     * 构造缩放弹出效果。
     * @param duration 时长（秒），默认 0.3。
     * @param back 淡入是否使用 <code>Back.easeOut</code>，默认 <code>true</code>。
     * @example
     * <listing version="3.0">
     * var ef:ZoomEffect = new ZoomEffect(0.3, true);
     * </listing>
     */
    public function ZoomEffect(duration:Number = 0.3, back:Boolean = true) {
        _duration = duration;
        _back     = back;
    }

    /** @private */
    private var _duration:Number;
    /** @private */
    private var _back:Boolean;

    /**
     * 从小到大缩放入场。
     * @param stage 目标场景。
     * @param complete 完成回调；可省略。
     * @example
     * <listing version="3.0">
     * new ZoomEffect().fadeIn(layer, onDone);
     * </listing>
     */
    public function fadeIn(stage:IStage, complete:Function = null):void {
        var z:Number        = 0.5;
        var d:DisplayObject = stage.display;
        var p:Point         = new Point(
            d.x + d.width * z / 2,
            d.y + d.height * z / 2
        );

        var to:Object = {scaleX: z, scaleY: z, x: p.x, y: p.y, onComplete: complete};
        if (_back) {
            to.ease = Back.easeOut;
        }

        TweenLite.from(stage.display, _duration, to);
    }

    /**
     * 缩小退场。
     * @param stage 目标场景。
     * @param complete 完成回调；可省略。
     * @example
     * <listing version="3.0">
     * new ZoomEffect().fadeOut(layer, onDone);
     * </listing>
     */
    public function fadeOut(stage:IStage, complete:Function = null):void {
        var z:Number        = 0.1;
        var d:DisplayObject = stage.display;
        var p:Point         = new Point(
            d.x + d.width / 2 - d.width * z,
            d.y + d.height / 2 - d.height * z
        );

        TweenLite.to(stage.display, _duration, {
            scaleX    : z,
            scaleY    : z,
            x         : p.x,
            y         : p.y,
            onComplete: complete
        });
    }
}
}
