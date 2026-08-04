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
import flash.display.Sprite;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.MouseEvent;
import flash.geom.Point;

import net.play5d.kyo.utils.KyoMath;

/**
 * 拖拽滑块时分派，<code>params</code> 为含 <code>x</code>/<code>y</code> 比例的 <code>Point</code>。
 * @eventType KyoUIEvent.UPDATE
 */
[Event(name='event-update', type='net.play5d.kyo.display.ui.KyoUIEvent')]
/**
 * 滚动条：在给定拖拽范围内拖动 UI，并按比例派发更新事件。
 *
 * @see IKyoScrollBar
 * @see KyoUIEvent
 * @see #TYPE_H
 * @see #TYPE_V
 * @see #update()
 */
public class KyoScrollBar extends EventDispatcher implements IKyoScrollBar {
    /**
     * 水平滚动条。
     */
    public static const TYPE_H:int = 0;
    /**
     * 垂直滚动条。
     */
    public static const TYPE_V:int = 1;

    /**
     * @param ui 可拖拽的滑块显示对象。
     * @param dragRange 拖拽范围：<code>x</code> 为起点，<code>y</code> 为终点。
     * @param type 方向，默认 <code>TYPE_V</code>。
     */
    public function KyoScrollBar(ui:Sprite, dragRange:Point, type:int = TYPE_V) {
        this.ui         = ui;
        this._dragRange = dragRange;
        this._type      = type;
        _distance       = _dragRange.y - _dragRange.x;

        ui.mouseChildren = false;
        ui.addEventListener(MouseEvent.MOUSE_DOWN, startDrag);
    }

    /**
     * 滑块 UI。
     */
    public var ui:Sprite;
    /** @private */
    private var _dragRange:Point;
    /** @private */
    private var _type:int;
    /** @private 可拖拽总长度 */
    private var _distance:Number;
    /** @private */
    private var _dragging:Boolean;

    /** @private */
    public function set enabled(v:Boolean):void {
        ui.mouseEnabled = v;
        if (!v) {
            endDrag();
        }
    }

    /**
     * 按 0–1 比例更新滑块位置（不派发事件）。
     * @param pos 滚动比例。
     * @example
     * <listing version="3.0">
     * bar.update(0.5);
     * </listing>
     */
    public function update(pos:Number):void {
        var pp:Number = pos * _distance;

        if (_type == TYPE_H) {
            ui.x = _dragRange.x + pp;
        }
        if (_type == TYPE_V) {
            ui.y = _dragRange.x + pp;
        }
    }

    /**
     * @private 开始拖拽。
     */
    private function startDrag(e:MouseEvent):void {
        if (_dragging) {
            return;
        }

        _dragging = true;

        ui.stage.addEventListener(MouseEvent.MOUSE_UP, endDrag);
        ui.addEventListener(Event.ENTER_FRAME, onEnterFrame);
    }

    /**
     * @private 拖拽中更新位置并派发 UPDATE。
     */
    private function onEnterFrame(e:Event):void {
        var pp:Number;
        var pos:Point = new Point();

        if (_type == TYPE_H) {
            pp    = KyoMath.fixRange(ui.parent.mouseX, _dragRange.x, _dragRange.y);
            ui.x  = pp;
            pos.x = (pp - _dragRange.x) / _distance;
        }
        if (_type == TYPE_V) {
            pp    = KyoMath.fixRange(ui.parent.mouseY, _dragRange.x, _dragRange.y);
            ui.y  = pp;
            pos.y = (pp - _dragRange.x) / _distance;
        }

        dispatchEvent(new KyoUIEvent(KyoUIEvent.UPDATE, pos));
    }

    /**
     * @private 结束拖拽。
     */
    private function endDrag(e:MouseEvent = null):void {
        _dragging = false;

        ui.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
        if (ui.stage) {
            ui.stage.removeEventListener(MouseEvent.MOUSE_UP, endDrag);
        }
    }
}
}
