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

package net.play5d.kyo.effect {
import com.greensock.TweenLite;
import com.greensock.plugins.ColorTransformPlugin;
import com.greensock.plugins.TweenPlugin;

import flash.display.Bitmap;
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.events.Event;
import flash.geom.ColorTransform;

import net.play5d.kyo.utils.KyoColor;
import net.play5d.kyo.utils.KyoDisplayUtils;

/**
 * 舞台级特效单例：闪白、衰减抖动、颜色变换、放大残影等。
 *
 * <p>使用前须先设置 <code>stage</code> 为目标显示对象。</p>
 *
 * @see #I
 * @see #stage
 * @see #shine()
 * @see #shake()
 */
public class StageEffect {
    /** @private */
    private static var _i:StageEffect;

    /**
     * 单例访问器。
     * @return <code>StageEffect</code> 唯一实例。
     * @example
     * <listing version="3.0">
     * StageEffect.I.stage = root;
     * StageEffect.I.shine(0.3);
     * </listing>
     */
    public static function get I():StageEffect {
        _i ||= new StageEffect();

        return _i;
    }

    /**
     * 构造函数；通常通过 <code>StageEffect.I</code> 获取实例。
     */
    public function StageEffect() {
    }

    /**
     * 特效作用的目标显示对象。
     * @default null
     */
    public var stage:DisplayObject;
    /** @private 抖动结束回调 */
    private var _shakeBack:Function;

    /**
     * 从指定着色过渡回当前颜色（闪屏感）。
     * @param duration 过渡时长（秒），默认 1。
     * @param color 闪烁着色，默认白色。
     * @param alpha 着色强度（tintAmount），默认 0.5。
     * @example
     * <listing version="3.0">
     * StageEffect.I.shine(0.4, KyoColor.WHITE, 0.6);
     * </listing>
     */
    public function shine(duration:Number = 1, color:uint = KyoColor.WHITE, alpha:Number = 0.5):void {
        TweenPlugin.activate([ColorTransformPlugin]);
        stage.transform.colorTransform = new ColorTransform();
        TweenLite.from(stage, duration, {colorTransform: {tint: color, tintAmount: alpha}});
    }

    /**
     * 衰减式屏幕抖动：幅度逐帧减小，结束后坐标归零并调用回调。
     * @param x 初始 X 抖动幅度。
     * @param y 初始 Y 抖动幅度。
     * @param back 结束回调，可选。
     * @param gapFrame 每隔多少帧更新一次位移，默认 1。
     * @example
     * <listing version="3.0">
     * StageEffect.I.shake(8, 8, onShakeEnd);
     * </listing>
     */
    public function shake(x:uint, y:uint, back:Function = null, gapFrame:int = 1):void {
        var dir:int = 1;
        var n:int;

        stage.x = stage.y = 0;

        invokeShakeBack();
        _shakeBack = back;

        stage.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
        stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);

        function invokeShakeBack():void {
            if (_shakeBack != null) {
                _shakeBack();
                _shakeBack = null;
            }
        }

        function onEnterFrame(e:Event):void {
            n++;
            if (n % gapFrame != 0) {
                return;
            }

            stage.x = x * dir;
            stage.y = y * dir;
            dir *= -1;

            if (n % 2 == 0) {
                if (x > 0) {
                    x--;
                }
                if (y > 0) {
                    y--;
                }
            }

            if (x <= 0 && y <= 0) {
                stage.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
                stage.x = 0;
                stage.y = 0;
                invokeShakeBack();
            }
        }
    }

    /**
     * 直接应用颜色变换到 <code>stage</code>。
     * @param ct 颜色变换。
     * @example
     * <listing version="3.0">
     * StageEffect.I.applyColorTransform(new ColorTransform());
     * </listing>
     */
    public function applyColorTransform(ct:ColorTransform):void {
        stage.transform.colorTransform = ct;
    }

    /**
     * 对当前 <code>stage</code> 截图并做放大淡出残影。
     * @example
     * <listing version="3.0">
     * StageEffect.I.bigShadow();
     * </listing>
     */
    public function bigShadow():void {
        var pt:DisplayObjectContainer = stage.parent;
        if (!pt) {
            return;
        }

        var bp:Bitmap = KyoDisplayUtils.drawDisplay(stage, false);
        pt.addChild(bp);
        bp.addEventListener(Event.ENTER_FRAME, onEnterFrame);

        function onEnterFrame(e:Event):void {
            bp.x -= 6.5;
            bp.y -= 6.5;
            bp.scaleX += 0.04;
            bp.scaleY += 0.04;
            bp.alpha -= 0.1;

            if (bp.alpha <= 0) {
                bp.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
                pt.removeChild(bp);
                bp.bitmapData.dispose();
                bp = null;
            }
        }
    }
}
}
