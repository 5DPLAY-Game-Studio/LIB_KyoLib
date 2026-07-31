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
import com.greensock.TweenLite;

import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.geom.Rectangle;

import net.play5d.kyo.utils.KyoUtils;

/**
 * iPhone 风格惯性滚动面板：内容超出可视区时可拖拽，松手后减速并回弹。
 *
 * @see #source
 * @see #scrollH
 * @see #scrollV
 * @see #move()
 */
public class IphoneScrollPane extends Sprite {
    /**
     * @param size 可视区域尺寸。
     */
    public function IphoneScrollPane(size:Point) {
        _size = size;
    }

    /**
     * 判定为拖拽的最小像素位移。
     * @default 5
     */
    public var dragPixel:int = 5;
    /**
     * 是否允许水平滚动。
     * @default true
     */
    public var H_enab:Boolean = true;
    /**
     * 是否允许垂直滚动。
     * @default true
     */
    public var V_enab:Boolean = true;
    /**
     * 是否响应拖拽。
     * @default true
     */
    public var enabled:Boolean = true;
    /** @private */
    private var _size:Point;
    /** @private 按下时舞台坐标 */
    private var _downPoint:Point;
    /** @private 是否已松手进入惯性阶段 */
    private var _release:Boolean;
    /** @private 惯性速度 */
    private var _mouseSpd:Point = new Point();
    /** @private 按下时的 scrollRect */
    private var _downSR:Rectangle;
    /** @private 是否已进入拖拽 */
    private var _draging:Boolean;
    /** @private */
    private var _source:DisplayObject;

    /**
     * 被滚动的内容显示对象。
     * @return 内容。
     * @default null
     */
    public function get source():DisplayObject {
        return _source;
    }

    /** @private */
    public function set source(value:DisplayObject):void {
        _source = value;
        addChild(_source);
        updateScrollRect();
        removeEventListener(MouseEvent.MOUSE_DOWN, beginDrag);
        addEventListener(MouseEvent.MOUSE_DOWN, beginDrag);

        graphics.clear();
        graphics.beginFill(0, 0);
        graphics.drawRect(0, 0, _source.width, _source.height);
        graphics.endFill();
    }

    /**
     * 水平滚动位置（内容向右为正时与 <code>-scrollRect.x</code> 对应）。
     * @return 水平滚动值。
     */
    public function get scrollH():Number {
        return -scrollRect.x;
    }

    /** @private */
    public function set scrollH(v:Number):void {
        scrollRect = new Rectangle(-v, scrollRect.y, _size.x, _size.y);
    }

    /**
     * 垂直滚动位置。
     * @return 垂直滚动值。
     */
    public function get scrollV():Number {
        return -scrollRect.y;
    }

    /** @private */
    public function set scrollV(v:Number):void {
        scrollRect = new Rectangle(scrollRect.x, -v, _size.x, _size.y);
    }

    /**
     * 移除拖拽相关监听。
     * @example
     * <listing version="3.0">
     * pane.destroy();
     * </listing>
     */
    public function destroy():void {
        removeEventListener(MouseEvent.MOUSE_DOWN, beginDrag);
        if (stage) {
            stage.removeEventListener(MouseEvent.MOUSE_UP, endDrag);
        }
    }

    /**
     * 按位移更新滚动（拖拽中或惯性阶段由内部调用）。
     * @param xx 水平位移。
     * @param yy 垂直位移，默认 0。
     */
    public function move(xx:Number, yy:Number = 0):void {
        var w:Number       = _size.x;
        var h:Number       = _size.y;
        var rect:Rectangle = new Rectangle(0, 0, w, h);
        if (_release) {
            rect = scrollRect.clone();
        }

        if (_release) {
            rect.x += _mouseSpd.x;
            rect.y += _mouseSpd.y;
        }
        else {
            rect.x      = xx;
            _mouseSpd.x = xx;

            rect.y      = yy;
            _mouseSpd.y = yy;
        }

        if (_downSR) {
            rect.x += _downSR.x;
            rect.y += _downSR.y;
        }
        if (_release) {
            _mouseSpd.x = KyoUtils.num_wake(_mouseSpd.x, 3);
            if (_mouseSpd.x > 6 && rect.x > (_source.width - _size.x) + 100) {
                _mouseSpd.x = -6;
            }
            if (_mouseSpd.x < -6 && rect.x < -100) {
                _mouseSpd.x = 6;
            }

            _mouseSpd.y = KyoUtils.num_wake(_mouseSpd.y, 3);
            if (_mouseSpd.y > 6 && rect.y > (_source.height - _size.y) + 100) {
                _mouseSpd.y = -6;
            }
            if (_mouseSpd.y < -6 && rect.y < -100) {
                _mouseSpd.y = 6;
            }

            if (KyoScrollDragUtil.isNearlyStopped(_mouseSpd.x, _mouseSpd.y)) {
                finalEndDrag();
            }
        }
        updateScrollRect(rect);
    }

    /**
     * @private 根据位移判断是否进入拖拽并禁用舞台子项鼠标。
     */
    protected function checkDraging(xx:Number, yy:Number):void {
        _draging = KyoScrollDragUtil.updateDragging(_draging, xx, yy, dragPixel, H_enab, V_enab, stage);
    }

    /**
     * @private 惯性结束：越界则 Tween 回弹。
     */
    private function finalEndDrag():void {
        removeEventListener(Event.ENTER_FRAME, draging);
        var rect:Rectangle = scrollRect.clone();
        var to:Object      = {};

        if (_source.width < _size.x) {
            to['x'] = 0;
        }
        else {
            if (rect.x < 0) {
                to['x'] = 0;
            }
            if (_size) {
                if (rect.x > _source.width - _size.x) {
                    to['x'] = _source.width - _size.x;
                }
            }
        }

        if (_source.height < _size.y) {
            to['y'] = 0;
        }
        else {
            if (rect.y < 0) {
                to['y'] = 0;
            }
            if (_size) {
                if (rect.y > _source.height - _size.y) {
                    to['y'] = _source.height - _size.y;
                }
            }
        }

        if (to['x'] != undefined || to['y'] != undefined) {
            to['onUpdate'] = function ():void {
                updateScrollRect(rect);
            };
            TweenLite.killTweensOf(rect);
            TweenLite.to(rect, 0.5, to);
        }

        removeListener();
    }

    /**
     * @private 移除舞台抬起监听并恢复 mouseChildren。
     */
    private function removeListener():void {
        if (stage) {
            stage.removeEventListener(MouseEvent.MOUSE_UP, endDrag);
        }
        KyoScrollDragUtil.setStageMouseChildren(stage, true);
    }

    /**
     * @private 相对按下点的鼠标位移（受 H/V 开关限制）。
     */
    private function mousePoint():Point {
        if (!stage) {
            return null;
        }
        return KyoScrollDragUtil.mouseDelta(_downPoint, stage.mouseX, stage.mouseY, H_enab, V_enab);
    }

    /**
     * @private 应用或重置 scrollRect。
     */
    private function updateScrollRect(rect:Rectangle = null):void {
        if (rect) {
            scrollRect = rect;
        }
        else {
            scrollRect = new Rectangle(0, 0, _size.x, _size.y);
        }
    }

    /**
     * @private 开始拖拽。
     */
    private function beginDrag(e:MouseEvent):void {
        if (!enabled) {
            return;
        }
        if (!_size) {
            return;
        }

        _downPoint = new Point(stage.mouseX, stage.mouseY);
        _downSR    = scrollRect;

        addEventListener(Event.ENTER_FRAME, draging);
        _draging = false;
        _release = false;
        if (stage) {
            stage.addEventListener(MouseEvent.MOUSE_UP, endDrag);
        }
    }

    /**
     * @private 松手进入惯性或直接结束。
     */
    private function endDrag(e:MouseEvent):void {
        _release = true;
        _downSR  = null;

        var mux:Point = mousePoint();
        if (!mux) {
            return;
        }

        _mouseSpd.x = mux.x - _mouseSpd.x;
        _mouseSpd.y = mux.y - _mouseSpd.y;

        if (KyoScrollDragUtil.isNearlyStopped(_mouseSpd.x, _mouseSpd.y, 5)) {
            finalEndDrag();
        }
    }

    /**
     * @private 拖拽帧更新。
     */
    private function draging(e:Event):void {
        var pp:Point = mousePoint();
        if (!pp) {
            return;
        }
        checkDraging(pp.x, pp.y);
        if (_draging) {
            move(pp.x, pp.y);
        }
    }

}
}
