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

package net.play5d.kyo.input {
import flash.display.Stage;
import flash.events.EventDispatcher;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.geom.Rectangle;

/**
 * 滑动时分派。
 * @eventType net.play5d.kyo.input.KyoTouchEvent.SLIDE
 */
[Event(name='event-slide', type='net.play5d.kyo.input.KyoTouchEvent')]
/**
 * 基于鼠标按下 / 抬起的滑动输入（模拟触摸滑动），派发 <code>KyoTouchEvent.SLIDE</code>。
 *
 * @see KyoTouchEvent
 * @see #slidePos
 * @see #enableArea
 * @see #enabled
 */
public class KyoTouchInput extends EventDispatcher {
    /**
     * @param stage 侦听鼠标事件的舞台。
     */
    public function KyoTouchInput(stage:Stage) {
        _stage  = stage;
        enabled = true;
    }

    /**
     * 判定为滑动所需的最小像素位移。
     * @default 20
     */
    public var slidePos:int = 20;
    /**
     * 可选有效区域；为 <code>null</code> 时全舞台有效。
     * 判定使用 <code>x/y/width/height</code>（非标准含宽高的矩形包含）。
     */
    public var enableArea:Rectangle;
    /** @private */
    private var _stage:Stage;
    /** @private */
    private var _downPoint:Point;
    /** @private */
    private var _enabled:Boolean;

    /**
     * 是否启用监听。
     * @return 当前是否已注册 Stage 鼠标监听。
     * @default true
     */
    public function get enabled():Boolean {
        return _enabled;
    }

    /** @private */
    public function set enabled(v:Boolean):void {
        _stage.removeEventListener(MouseEvent.MOUSE_DOWN, mouseHandler);
        _stage.removeEventListener(MouseEvent.MOUSE_UP, mouseHandler);

        _enabled = v;
        if (v) {
            _stage.addEventListener(MouseEvent.MOUSE_DOWN, mouseHandler);
            _stage.addEventListener(MouseEvent.MOUSE_UP, mouseHandler);
        }
    }

    /**
     * @private 点是否在 enableArea 内。
     */
    private function checkArea(sx:Number, sy:Number):Boolean {
        if (enableArea) {
            if (sx > enableArea.width || sx < enableArea.x) {
                return false;
            }
            if (sy > enableArea.height || sy < enableArea.y) {
                return false;
            }
        }

        return true;
    }

    /**
     * @private 根据按下点与当前鼠标位置派发滑动事件。
     */
    private function doSlide():void {
        if (!_downPoint) {
            return;
        }
        if (!checkArea(_stage.mouseX, _stage.mouseY)) {
            return;
        }

        var dx:Number = _stage.mouseX - _downPoint.x;
        var dy:Number = _stage.mouseY - _downPoint.y;

        if (Math.abs(dx) >= Math.abs(dy)) {
            if (dx > slidePos) {
                dispatchEvent(new KyoTouchEvent(KyoTouchEvent.SLIDE, {direction: KyoTouchEvent.DIRECTION_RIGHT}));
            }
            if (dx < -slidePos) {
                dispatchEvent(new KyoTouchEvent(KyoTouchEvent.SLIDE, {direction: KyoTouchEvent.DIRECTION_LEFT}));
            }
        }
        else {
            if (dy > slidePos) {
                dispatchEvent(new KyoTouchEvent(KyoTouchEvent.SLIDE, {direction: KyoTouchEvent.DIRECTION_DOWN}));
            }
            if (dy < -slidePos) {
                dispatchEvent(new KyoTouchEvent(KyoTouchEvent.SLIDE, {direction: KyoTouchEvent.DIRECTION_UP}));
            }
        }
    }

    /**
     * @private
     */
    private function mouseHandler(e:MouseEvent):void {
        switch (e.type) {
        case MouseEvent.MOUSE_DOWN:
            var sx:Number = _stage.mouseX;
            var sy:Number = _stage.mouseY;
            if (!checkArea(sx, sy)) {
                return;
            }
            _downPoint = new Point(sx, sy);
            break;
        case MouseEvent.MOUSE_UP:
            doSlide();
            _downPoint = null;
            break;
        }
    }
}
}
