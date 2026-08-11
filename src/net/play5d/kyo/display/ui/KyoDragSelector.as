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
import flash.events.Event;
import flash.events.MouseEvent;

/**
 * 选中项变化时分派。
 * @eventType KyoDragSelector.EVENT_CHANGE
 */
[Event(name='select-change-event', type='flash.events.Event')]
/**
 * 拖拽选择列表：垂直拖动整表定位选中项，松手后吸附并对齐。
 *
 * <p>可通过 <code>changeEffectObj</code> 按与选中项的距离缩放等属性做视觉强调。</p>
 *
 * @see KyoDragList
 * @see #selectItem
 * @see #changeEffectObj
 */
public class KyoDragSelector extends KyoDragList {
    /**
     * <code>select-change-event</code> 事件的 <code>type</code> 属性值。
     * @eventType select-change-event
     */
    public static const EVENT_CHANGE:String = 'select-change-event';

    /**
     * @param displays 显示对象数组。
     * @param dragType 拖拽方向，默认垂直。
     * @param hRow 横排最大个数。
     * @param vRow 竖排最大个数。
     */
    public function KyoDragSelector(
        displays:Array,
        dragType:int = KyoDragType.DRAG_TYPE_V,
        hRow    :int = int.MAX_VALUE,
        vRow    :int = 1
    ) {
        super(displays, dragType, hRow, vRow);
        mouseChildren = false;
        _forceDrag   = true;
    }

    /**
     * 选中距离效果配置：键为属性名，值为非选中项衰减系数基准。
     * @default null
     */
    public var changeEffectObj:Object;
    /** @private 当前选中索引 */
    private var _selectId:int;
    /** @private */
    private var _selectItem:DisplayObject;

    /**
     * 当前选中的显示对象。
     * @return 选中项。
     * @default null
     */
    public function get selectItem():DisplayObject {
        return _selectItem;
    }

    /** @private */
    public function set selectItem(value:DisplayObject):void {
        _selectItem = value;

        _selectId = displays.indexOf(_selectItem);
        if (_selectId != -1) {
            dragComplete();
        }
    }

    /** @inheritDoc */
    public override function update():void {
        super.update();
        displayUpdate();
    }

    /**
     * @private 吸附到当前选中索引；可选派发变化事件。
     */
    private function dragComplete(sendEvent:Boolean = false):void {
        var to:Object = {
            onComplete: function ():void {
                mouseEnabled = true;
                displayUpdate();
                if (sendEvent) {
                    dispatchEvent(new Event(EVENT_CHANGE));
                }
            }
        };
        switch (dragType) {
        case KyoDragType.DRAG_TYPE_H:
            break;
        case KyoDragType.DRAG_TYPE_V:
            to['y']     = -_selectId * (unitSize.y + gap.y);
            _selectItem = displays[_selectId];
            break;
        }
        TweenLite.to(this, .2, to);
    }

    /**
     * @private 按位置计算选中索引，并应用 <code>changeEffectObj</code>。
     */
    private function displayUpdate():void {
        var uh:Number = unitSize.y + gap.y;
        _selectId       = (-this.y + unitSize.y / 2) / uh;
        if (_selectId < 0) {
            _selectId = 0;
        }
        if (_selectId > displays.length - 1) {
            _selectId = displays.length - 1;
        }

        if (changeEffectObj) {
            for (var i:int; i < displays.length; i++) {
                var d:DisplayObject = displays[i];
                var ms:int          = Math.abs(i - _selectId);
                for (var s:String in changeEffectObj) {
                    d[s] = ms == 0 ? 1 : (1 / ms) * changeEffectObj[s];
                }
            }
        }
    }

    /** @inheritDoc */
    protected override function onDragging(e:Event):void {
        var xx:Number = stage.mouseX - _downPoint.x;
        var yy:Number = stage.mouseY - _downPoint.y;
        checkDragging(xx, yy);

        if (!_dragging) {
            return;
        }

        switch (dragType) {
        case KyoDragType.DRAG_TYPE_H:
            break;
        case KyoDragType.DRAG_TYPE_V:
            this.y = _downListPoint.y + yy;
            break;
        }
        displayUpdate();
    }

    /** @inheritDoc */
    protected override function endDrag(e:MouseEvent):void {
        removeListener();
        removeEventListener(Event.ENTER_FRAME, onDragging);
        mouseEnabled = false;
        dragComplete(true);
    }
}
}
