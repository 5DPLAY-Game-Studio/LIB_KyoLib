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
import flash.display.Bitmap;
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.MovieClip;
import flash.events.Event;
import flash.geom.ColorTransform;
import flash.geom.Point;
import flash.geom.Rectangle;

import net.play5d.kyo.utils.KyoDisplayUtils;

/**
 * 显示对象特效工具（残影、缩放影、MC 一次性特效、抖动等）。
 *
 * @see GhostShadowColorTransform
 * @see StageEffect
 * @see #ghostShadow()
 * @see #zoomShadow()
 * @see #mcEffect()
 * @see #shake()
 */
public class DisplayEffect {
    /**
     * 在目标当前位置留下残影，逐帧降低透明度后移除。
     * @param d 被截图的显示对象（须已有 parent）。
     * @param alphaLoss 每帧减少的透明度，默认 0.1。
     * @param startAlpha 残影初始透明度，默认 1。
     * @param colorTransform 残影颜色变换，可选。
     * @example
     * <listing version="3.0">
     * DisplayEffect.ghostShadow(hero, 0.1, 1, GhostShadowColorTransform.red);
     * </listing>
     * @see GhostShadowColorTransform
     * @see #zoomShadow()
     */
    public static function ghostShadow(
        d             :DisplayObject,
        alphaLoss     :Number = 0.1,
        startAlpha    :Number = 1,
        colorTransform:ColorTransform = null
    ):void {
        var pt:DisplayObjectContainer = d.parent;
        if (!pt) {
            return;
        }

        var params:Object = {
            parent   : pt,
            alphaLoss: alphaLoss
        };
        var bitmapParams:Object = {
            alpha: startAlpha
        };

        var bp:InsShadow = createInsShadow(d, params, bitmapParams);
        if (!bp) {
            return;
        }
        if (colorTransform) {
            bp.bitmap.transform.colorTransform = colorTransform;
        }

        pt.addChild(bp.bitmap);
        pt.addChild(d);

        bp.initialize();
    }

    /**
     * 缩放残影：截图后逐帧放大并淡出。
     * @param d 被截图的显示对象。
     * @param scaleAdd 每帧缩放增量，默认 0.1。
     * @param alphaLoss 每帧透明度减量，默认 0.05。
     * @param startAlpha 初始透明度，默认 1。
     * @param colorTransform 颜色变换，可选。
     * @param parent 残影父容器；默认 <code>d.parent</code>。
     * @param size 用于计算缩放中心偏移的参考尺寸；默认取截图宽高。
     * @return 残影位图；无法创建时返回 <code>null</code>。
     * @example
     * <listing version="3.0">
     * DisplayEffect.zoomShadow(hero, 0.08, 0.05);
     * </listing>
     * @see #ghostShadow()
     */
    public static function zoomShadow(
        d             :DisplayObject,
        scaleAdd      :Number = .1,
        alphaLoss     :Number = 0.05,
        startAlpha    :Number = 1,
        colorTransform:ColorTransform = null,
        parent        :DisplayObjectContainer = null,
        size          :Point = null
    ):DisplayObject {
        parent ||= d.parent;
        if (!parent) {
            return null;
        }

        var params:Object = {
            parent   : parent,
            alphaLoss: alphaLoss,
            scaleAdd : scaleAdd
        };
        var bitmapParams:Object = {
            alpha: startAlpha
        };

        var bp:InsShadow = createInsShadow(d, params, bitmapParams, size);
        if (!bp) {
            return null;
        }
        if (colorTransform) {
            bp.bitmap.transform.colorTransform = colorTransform;
        }

        parent.addChild(bp.bitmap);
        bp.initialize();

        return bp.bitmap;
    }

    /**
     * 在容器中播放一次性 MovieClip 特效，播完后自动移除。
     * @param child 父容器。
     * @param effect 继承 <code>MovieClip</code> 的类。
     * @param pos 放置坐标；为 <code>null</code> 时用默认 (0,0)。
     * @return 已加入显示列表并开始播放的实例。
     * @example
     * <listing version="3.0">
     * DisplayEffect.mcEffect(layer, HitFx, new Point(100, 80));
     * </listing>
     */
    public static function mcEffect(child:DisplayObjectContainer, effect:Class, pos:Point = null):MovieClip {
        var mc:MovieClip = new effect();
        mc.mouseEnabled  = mc.mouseChildren = false;

        if (pos) {
            mc.x = pos.x;
            mc.y = pos.y;
        }

        mc.addFrameScript(mc.totalFrames - 1, function ():void {
            mc.stop();
            mc.parent.removeChild(mc);
            mc = null;
        });
        mc.gotoAndPlay(1);
        child.addChild(mc);

        return mc;
    }

    /**
     * 对显示对象做短时位移抖动（结束后坐标归零）。
     * @param stage 被抖动的对象（参数名沿用历史命名）。
     * @param frames 持续帧数，默认 1。
     * @param strength 每帧位移幅度，默认 2。
     * @example
     * <listing version="3.0">
     * DisplayEffect.shake(stageRoot, 6, 3);
     * </listing>
     */
    public static function shake(stage:DisplayObject, frames:int = 1, strength:int = 2):void {
        stage.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
        stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);

        var frame:int;

        function onEnterFrame(e:Event):void {
            frame++;
            if (frame > frames) {
                stage.x = 0;
                stage.y = 0;
                stage.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
                return;
            }

            var dir:int = frame % 2 == 0 ? 1 : -1;
            stage.x += strength * dir;
            stage.y += strength * dir;
        }
    }

    /**
     * @private 截取显示对象为残影并填充参数。
     */
    private static function createInsShadow(
        d           :DisplayObject,
        params      :Object = null,
        bitmapParams:Object = null,
        size        :Point = null
    ):InsShadow {
        var bmp:Bitmap = KyoDisplayUtils.drawDisplay(d);
        if (!bmp) {
            return null;
        }

        var bp:InsShadow = new InsShadow();
        bp.bitmap        = bmp;
        bp.bitmap.scaleX = d.scaleX;
        bp.bitmap.scaleY = d.scaleY;

        var bds:Rectangle = d.getBounds(d);
        bp.bitmap.x       = d.x + bds.x * d.scaleX;
        bp.bitmap.y       = d.y + bds.y * d.scaleY;
        bp.size           = size;

        var key:String;
        if (params) {
            for (key in params) {
                bp[key] = params[key];
            }
        }
        if (bitmapParams) {
            for (key in bitmapParams) {
                bp.bitmap[key] = bitmapParams[key];
            }
        }

        return bp;
    }
}
}

import flash.display.Bitmap;
import flash.display.DisplayObjectContainer;
import flash.events.Event;
import flash.geom.Point;

/**
 * 残影运行时数据与逐帧更新。
 * @private
 */
internal class InsShadow {
    /** @private 残影位图 */
    public var bitmap:Bitmap;
    /** @private 每帧透明度减量 */
    public var alphaLoss:Number = 0.1;
    /** @private 残影所在容器 */
    public var parent:DisplayObjectContainer;
    /** @private 每帧缩放增量；0 表示不缩放 */
    public var scaleAdd:Number = 0;
    /** @private 参考尺寸，用于缩放时的位置补偿 */
    public var size:Point;
    /** @private 考虑镜像后的每帧缩放增量 */
    private var _scaleAddP:Point;
    /** @private 缩放时每帧位置回退量 */
    private var _poLose:Point;

    /**
     * @private 启动 ENTER_FRAME 更新。
     */
    public function initialize():void {
        _scaleAddP = new Point(scaleAdd, scaleAdd);
        size ||= new Point(bitmap.width, bitmap.height);
        _poLose = new Point(size.x * scaleAdd / 2, size.y * scaleAdd / 2);

        if (bitmap.scaleX < 0) {
            _scaleAddP.x *= -1;
            _poLose.x *= -1;
        }

        bitmap.addEventListener(Event.ENTER_FRAME, onEnterFrame);
    }

    /**
     * @private 淡出 / 缩放，结束后移除并 dispose。
     */
    private function onEnterFrame(e:Event):void {
        bitmap.alpha -= alphaLoss;

        if (scaleAdd != 0) {
            bitmap.scaleX += _scaleAddP.x;
            bitmap.scaleY += _scaleAddP.y;
            bitmap.x -= _poLose.x;
            bitmap.y -= _poLose.y;
        }

        if (bitmap.alpha <= 0) {
            bitmap.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
            parent.removeChild(bitmap);
            bitmap.bitmapData.dispose();
            bitmap = null;
        }
    }
}
