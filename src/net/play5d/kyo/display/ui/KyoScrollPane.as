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
import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.geom.Rectangle;

import net.play5d.kyo.utils.KyoColor;

/**
 * 可拖拽滚动面板：内容超出 <code>maskSize</code> 时可拖动，并可同步外部滚动条。
 *
 * @see KyoDragType
 * @see IKyoScrollBar
 * @see #source
 * @see #move()
 */
public class KyoScrollPane extends Sprite {
    /**
     * @param maskSize 可视区域尺寸。
     * @param source 内容显示对象，可选。
     * @param dragType 拖拽方向，默认垂直。
     */
    public function KyoScrollPane(maskSize:Point, source:DisplayObject = null, dragType:int = KyoDragType.DRAG_TYPE_V) {
        this.dragType = dragType;
        this.maskSize = maskSize;
        if (source) {
            this.source = source;
        }

        this.addEventListener(MouseEvent.MOUSE_DOWN, beginDrag);
    }

    /**
     * 拖拽方向，见 <code>KyoDragType</code>。
     */
    public var dragType:int;
    /**
     * 可视区域尺寸。
     */
    public var maskSize:Point;
    /**
     * 可选联动滚动条。
     * @default null
     */
    public var scrollBar:IKyoScrollBar;
    /**
     * 判定为拖拽的最小像素位移。
     * @default 5
     */
    public var dragPixel:int = 5;
    /** @private 按下时舞台坐标 */
    protected var _downPoint:Point;
    /** @private 是否已进入拖拽 */
    protected var _draging:Boolean;
    /** @private 按下时 scrollRect */
    private var _downSR:Rectangle;
    /** @private 内容宽 */
    private var _width:Number;
    /** @private 内容高 */
    private var _height:Number;
    /** @private */
    private var _source:DisplayObject;

    /**
     * 被滚动的内容。
     * @return 内容显示对象。
     * @default null
     */
    public function get source():DisplayObject {
        return _source;
    }

    /** @private */
    public function set source(value:DisplayObject):void {
        _source = value;

        _source.x = _source.y = 0;
        addChild(_source);
        update();
    }

    /**
     * @private 相对按下点的鼠标位移。
     * @return 相对按下点的 <code>Point</code>。
     */
    protected function get mousePoint():Point {
        return KyoScrollDragUtil.mouseDelta(_downPoint, stage.mouseX, stage.mouseY);
    }

    /**
     * @private 内容是否超出可视区，允许拖拽。
     */
    private function get allowDrag():Boolean {
        switch (dragType) {
        case KyoDragType.DRAG_TYPE_BOTH:
            if ((_width < maskSize.x) && (_height < maskSize.y)) {
                return false;
            }
            break;
        case KyoDragType.DRAG_TYPE_H:
            if (_width < maskSize.x) {
                return false;
            }
            break;
        case KyoDragType.DRAG_TYPE_V:
            if (_height < maskSize.y) {
                return false;
            }
        }
        return true;
    }

    /**
     * 移除拖拽相关监听。
     * @example
     * <listing version="3.0">
     * pane.destroy();
     * </listing>
     */
    public function destroy():void {
        this.removeEventListener(MouseEvent.MOUSE_DOWN, beginDrag);
        removeEventListener(Event.ENTER_FRAME, draging);
        if (stage) {
            stage.removeEventListener(MouseEvent.MOUSE_UP, endDrag);
        }
    }

    /**
     * 根据内容尺寸刷新命中区域与 scrollRect，并更新滚动条。
     * @example
     * <listing version="3.0">
     * pane.update();
     * </listing>
     */
    public function update():void {
        _width  = _source.width;
        _height = _source.height;

        scrollRect = new Rectangle(0, 0, maskSize.x, maskSize.y);

        graphics.clear();
        graphics.beginFill(KyoColor.BLACK, 0);
        graphics.drawRect(0, 0, _width, _height);
        graphics.endFill();

        updateScrollBar();
    }

    /**
     * 按增量平移滚动位置（内部会夹紧到合法范围）。
     * @param x 水平增量（内容方向）。
     * @param y 垂直增量。
     * @example
     * <listing version="3.0">
     * pane.move(0, 20);
     * </listing>
     */
    public function move(x:Number, y:Number):void {
        var rect:Rectangle = scrollRect.clone();
        rect.x -= x;
        rect.y -= y;
        checkout(rect);
        scrollRect = rect;
    }

    /**
     * @private 移除舞台抬起监听并恢复 mouseChildren。
     */
    protected final function removeListener():void {
        if (stage) {
            stage.removeEventListener(MouseEvent.MOUSE_UP, endDrag);
        }
        KyoScrollDragUtil.setStageMouseChildren(stage, true);
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
     * @private 同步外部滚动条位置。
     */
    protected function updateScrollBar():void {
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
     * @private 将 rect 夹紧到可滚动范围。
     */
    private function checkout(rect:Rectangle):void {
        KyoScrollDragUtil.clampScrollOrigin(rect, _width, _height, maskSize.x, maskSize.y);
    }

    /**
     * @private 拖拽帧更新。
     * @param e <code>ENTER_FRAME</code> 事件。
     */
    protected function draging(e:Event):void {
        var pp:Point = mousePoint;
        checkDraging(pp.x, pp.y);
        var w:Number       = maskSize.x;
        var h:Number       = maskSize.y;
        var rect:Rectangle = new Rectangle(0, 0, w, h);
        switch (dragType) {
        case KyoDragType.DRAG_TYPE_BOTH:
            rect.x = pp.x;
            rect.y = pp.y;
            break;
        case KyoDragType.DRAG_TYPE_H:
            rect.x = pp.x;
            break;
        case KyoDragType.DRAG_TYPE_V:
            rect.y = pp.y;
            break;
        }
        if (_draging) {
            if (_downSR) {
                rect.x += _downSR.x;
                rect.y += _downSR.y;
            }
            checkout(rect);

            scrollRect = rect;
            updateScrollBar();
        }
    }

    /**
     * @private 结束拖拽。
     * @param e 鼠标事件。
     */
    protected function endDrag(e:MouseEvent):void {
        removeListener();
        removeEventListener(Event.ENTER_FRAME, draging);
    }

    /**
     * @private 开始拖拽。
     */
    private function beginDrag(e:MouseEvent):void {
        if (!allowDrag) {
            return;
        }

        _downSR    = scrollRect;
        _downPoint = new Point(stage.mouseX, stage.mouseY);

        addEventListener(Event.ENTER_FRAME, draging);
        _draging = false;
        if (stage) {
            stage.addEventListener(MouseEvent.MOUSE_UP, endDrag);
        }
    }

}
}
