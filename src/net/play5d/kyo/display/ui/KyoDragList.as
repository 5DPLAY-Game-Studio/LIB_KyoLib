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

import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.utils.Timer;

import net.play5d.kyo.utils.KyoMath;
/**
 * 可拖拽的瓦片列表，支持水平 / 垂直 / 双向拖拽、惯性回弹与自动滚动。
 *
 * @see KyoTileList
 * @see KyoDragType
 * @see KyoDragSelecter
 * @see #move()
 * @see #autoScroll()
 */
public class KyoDragList extends KyoTileList {
    /**
     * @param dispalys 显示对象数组（参数名沿用历史拼写）。
     * @param dragType 拖拽方向，默认垂直。
     * @param hrow 横排最大个数。
     * @param vrow 竖排最大个数。
     */
    public function KyoDragList(
        dispalys:Array,
        dragType:int = KyoDragType.DRAG_TYPE_V,
        hrow    :int = int.MAX_VALUE,
        vrow    :int = 1
    ) {
        super(dispalys, hrow, vrow);
        this.dragType = dragType;
        addEventListener(MouseEvent.MOUSE_DOWN, beginDrag);
    }

    /**
     * 拖拽方向，见 <code>KyoDragType</code>。
     */
    public var dragType:int;
    /**
     * 判定为拖拽的最小像素位移。
     * @default 5
     */
    public var dragPixel:int = 5;
    /** @private 按下时舞台坐标 */
    protected var _downPoint:Point;
    /** @private 按下时列表坐标（子类可用） */
    protected var _downListPoint:Point;
    /** @private 为 true 时即使内容未超出也可拖拽 */
    protected var _haveToDrag:Boolean;
    /** @private 是否已进入拖拽 */
    protected var _draging:Boolean;
    /** @private */
    private var _tween:TweenLite;
    /** @private 惯性速度 */
    private var _mouseSpd:Number = 0;
    /** @private 是否松手惯性阶段 */
    private var _release:Boolean;
    /** @private 自动滚动计时器 */
    private var _asctimer:Timer;
    /** @private 自动滚动缓动时长 */
    private var _tweenDuration:Number;
    /** @private 每页可视单元数 */
    private var _perpage:int;
    /** @private 当前对齐单元索引 */
    private var _curid:int;
    /** @private 按下时 scrollRect */
    private var _downSR:Rectangle;

    /**
     * @inheritDoc
     */
    public override function update():void {
        super.update();
        this.graphics.beginFill(0, 0);
        this.graphics.drawRect(0, 0, _width, _height);
        this.graphics.endFill();
    }

    /**
     * @inheritDoc
     */
    protected override function updateScrollBar():void {
        if (!scrollBar) {
            return;
        }
        switch (dragType) {
        case KyoDragType.DRAG_TYPE_BOTH:
            break;
        case KyoDragType.DRAG_TYPE_H:
            scrollBar.update(scrollRect.x / _width);
            break;
        case KyoDragType.DRAG_TYPE_V:
            scrollBar.update(scrollRect.y / _height);
            break;
        }
    }

    /**
     * 移除拖拽与自动滚动相关监听。
     * @example
     * <listing version="3.0">
     * list.destroy();
     * </listing>
     */
    public function destroy():void {
        removeEventListener(Event.ENTER_FRAME, draging);
        removeEventListener(MouseEvent.MOUSE_DOWN, beginDrag);
        if (stage) {
            stage.removeEventListener(MouseEvent.MOUSE_UP, endDrag);
        }
    }

    /**
     * 滚动到指定单元索引位置。
     * @param id 单元索引。
     * @param tweenTime 缓动时长（秒）；为 0 则立即定位。
     * @example
     * <listing version="3.0">
     * list.moveById(3, 0.4);
     * </listing>
     * @see #move()
     */
    public function moveById(id:int, tweenTime:Number = 0):void {
        var xx:Number = (unitySize.x + gap.x) * id;
        var yy:Number = (unitySize.y + gap.y) * id;
        if (tweenTime == 0) {
            move(xx, yy);
        }
        else {
            var o:Object = {};
            o.x          = scrollRect.x;
            o.y          = scrollRect.y;
            _tween       = TweenLite.to(o, tweenTime, {
                x       : xx,
                y       : yy,
                onUpdate: function ():void {
                    move(o.x, o.y);
                }
            });
        }
    }

    /**
     * 按位移更新滚动区域（拖拽 / 惯性内部调用）。
     * @param xx 水平位移。
     * @param yy 垂直位移，默认 0。
     */
    public function move(xx:Number, yy:Number = 0):void {
        var w:Number       = maskSize ? maskSize.x : _width;
        var h:Number       = maskSize ? maskSize.y : _height;
        var rect:Rectangle = new Rectangle(0, 0, w, h);
        if (_release) {
            rect = scrollRect.clone();
        }
        switch (dragType) {
        case KyoDragType.DRAG_TYPE_BOTH:
            rect.x = xx;
            rect.y = yy;
            break;
        case KyoDragType.DRAG_TYPE_H:
            if (_release) {
                rect.x += _mouseSpd;
                if (rect.x < 0 || rect.x > (_width - maskSize.x)) {
                    _mouseSpd /= 10;
                }
            }
            else {
                rect.x    = xx;
                _mouseSpd = xx;
            }
            break;
        case KyoDragType.DRAG_TYPE_V:
            if (_release) {
                rect.y += _mouseSpd;
                if (rect.y < 0 || rect.y > (_height - maskSize.y)) {
                    _mouseSpd /= 10;
                }
            }
            else {
                rect.y    = yy;
                _mouseSpd = yy;
            }
            break;
        }
        if (_release) {
            _mouseSpd = KyoMath.wake(_mouseSpd, 3);
            if (rect.y > _height) {
                _mouseSpd = 0;
            }
            if (rect.y < -w * 0.8) {
                _mouseSpd = 0;
            }
            if (KyoScrollDragUtil.isNearlyStopped(_mouseSpd)) {
                finalEndDrag();
            }
        }
        if (_downSR) {
            rect.x += _downSR.x;
            rect.y += _downSR.y;
        }
        updateScrollRect(rect);
        updateScrollBar();
    }

    /**
     * 启动自动按页滚动。
     * @param time 间隔时间（毫秒）。
     * @param tweenDuration 每次滚动缓动时长（秒），默认 1。
     * @example
     * <listing version="3.0">
     * list.autoScroll(3000, 0.8);
     * </listing>
     */
    public function autoScroll(time:int, tweenDuration:Number = 1):void {
        _tweenDuration = tweenDuration;
        _perpage       = Math.round(maskSize.y / (unitySize.y + gap.y));

        _asctimer = new Timer(time);
        _asctimer.addEventListener(TimerEvent.TIMER, onTimerScroll);
        _asctimer.start();
    }

    /**
     * @private 移除舞台抬起监听并恢复 mouseChildren。
     */
    protected final function removeListener():void {
        if (stage) {
            stage.removeEventListener(MouseEvent.MOUSE_UP, endDrag);
        }
        KyoScrollDragUtil.setStageMouseChildren(stage, true);
        removeEventListener(Event.ENTER_FRAME, draging);
    }

    /**
     * @private 相对按下点的鼠标位移。
     * @return 相对按下点的 <code>Point</code>。
     */
    protected function mousePoint():Point {
        return KyoScrollDragUtil.mouseDelta(_downPoint, stage.mouseX, stage.mouseY);
    }

    /**
     * @private 根据位移判断是否进入拖拽。
     * @param xx 水平位移。
     * @param yy 垂直位移。
     */
    protected function checkDraging(xx:Number, yy:Number):void {
        _draging = KyoScrollDragUtil.updateDragging(
            _draging, xx, yy, dragPixel,
            KyoScrollDragUtil.allowH(dragType),
            KyoScrollDragUtil.allowV(dragType),
            stage
        );
    }

    /**
     * @private 应用 scrollRect。
     */
    private function updateScrollRect(rect:Rectangle = null):void {
        rect ||= scrollRect;
        scrollRect = rect;
    }

    /**
     * @private 惯性结束：越界回弹并吸附到单元。
     */
    private function finalEndDrag():void {
        var rect:Rectangle = scrollRect.clone();
        var to:Object      = {};

        switch (dragType) {
        case KyoDragType.DRAG_TYPE_H:
            if (rect.x < 0) {
                to['x'] = 0;
            }
            if (maskSize) {
                if (rect.x > _width - maskSize.x) {
                    to['x'] = _width - maskSize.x;
                }
            }
            break;
        case KyoDragType.DRAG_TYPE_V:
            if (rect.y < 0) {
                to['y'] = 0;
            }
            if (maskSize) {
                if (rect.y > _height - maskSize.y) {
                    to['y'] = _height - maskSize.y;
                }
            }
            break;
        }
        if (to['x'] != undefined || to['y'] != undefined) {
            to['onUpdate']   = function ():void {
                updateScrollRect(rect);
            };
            to['onComplete'] = tweenover;
            _tween           = TweenLite.to(rect, 0.5, to);
        }
        else {
            tweenover();
        }
        removeListener();

        function tweenover():void {
            _release = false;
            switch (dragType) {
            case KyoDragType.DRAG_TYPE_H:
                _curid = Math.round(scrollRect.x / unitySize.x);
                break;
            case KyoDragType.DRAG_TYPE_V:
                _curid = Math.round(scrollRect.y / unitySize.y);
                break;
            }
            moveById(_curid, 0.5);
            if (_asctimer) {
                _asctimer.reset();
                _asctimer.start();
            }
        }
    }

    /**
     * @private 松手：进入惯性或恢复自动滚动。
     * @param e 鼠标事件。
     */
    protected function endDrag(e:MouseEvent):void {
        _downSR = null;
        if (!_draging) {
            removeListener();
            if (_asctimer) {
                _asctimer.reset();
                _asctimer.start();
            }
            return;
        }

        _release = true;

        var mux:Point = mousePoint();

        switch (dragType) {
        case KyoDragType.DRAG_TYPE_H:
            _mouseSpd = mux.x - _mouseSpd;
            break;
        case KyoDragType.DRAG_TYPE_V:
            _mouseSpd = mux.y - _mouseSpd;
            break;
        }
        if (KyoScrollDragUtil.isNearlyStopped(_mouseSpd, 0, 5)) {
            finalEndDrag();
        }
    }

    /**
     * @private 拖拽帧更新。
     * @param e <code>ENTER_FRAME</code> 事件。
     */
    protected function draging(e:Event):void {
        var pp:Point = mousePoint();
        checkDraging(pp.x, pp.y);
        if (_draging) {
            move(pp.x, pp.y);
        }
    }

    /**
     * @private 自动滚动计时回调。
     */
    private function onTimerScroll(e:TimerEvent):void {
        if (_curid > displays.length - _perpage - 1) {
            _curid = 0;
            moveById(_curid, _tweenDuration);
        }
        else {
            moveById(++_curid, _tweenDuration);
        }
    }

    /**
     * @private 开始拖拽；动画进行中或内容未超出时可能直接返回。
     */
    private function beginDrag(e:MouseEvent):void {
        if (_tween && _tween._active) {
            return;
        }

        if (!_haveToDrag) {
            if (!maskSize) {
                return;
            }
            switch (dragType) {
            case KyoDragType.DRAG_TYPE_H:
                if (_width < maskSize.x) {
                    return;
                }
                break;
            case KyoDragType.DRAG_TYPE_V:
                if (_height < maskSize.y) {
                    return;
                }
                break;
            }
        }

        if (_asctimer) {
            _asctimer.stop();
        }

        _downSR        = scrollRect;
        _downPoint     = new Point(stage.mouseX, stage.mouseY);
        _downListPoint = new Point(this.x, this.y);

        addEventListener(Event.ENTER_FRAME, draging);
        _draging = false;
        _release = false;
        if (stage) {
            stage.addEventListener(MouseEvent.MOUSE_UP, endDrag);
        }
    }
}
}
