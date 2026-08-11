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
import flash.events.Event;
import flash.geom.Point;
import flash.geom.Rectangle;

/**
 * 在固定可视尺寸内循环滚动显示对象的 <code>scrollRect</code>。
 *
 * @see #start()
 * @see #stop()
 * @see #speed
 */
public class KyoScroller {
    /**
     * @param d 被滚动的显示对象。
     * @param size 可视区域尺寸。
     * @param dsize 内容尺寸；为 <code>null</code> 时取 <code>d</code> 的宽高。
     */
    public function KyoScroller(d:DisplayObject, size:Point, dsize:Point = null) {
        _d     = d;
        _size  = size;
        _dsize = dsize ||= new Point(_d.width, _d.height);

        updateSC();
    }

    /**
     * 每帧滚动像素速度。
     * @default 2
     */
    public var speed:Number = 2;
    /** @private */
    private var _d:DisplayObject;
    /** @private */
    private var _size:Point;
    /** @private */
    private var _dsize:Point;
    /** @private 当前 scrollRect 原点 */
    private var _p:Point = new Point();
    /** @private 滚动方向 */
    private var _direction:int;

    /**
     * 开始滚动。
     * @param direct 方向：1 右→左，2 左→右，3 上→下，4 下→上；默认 1。
     * @example
     * <listing version="3.0">
     * scroller.start(1);
     * </listing>
     * @see #stop()
     */
    public function start(direct:int = 1):void {
        _direction = direct;

        stop();
        _d.addEventListener(Event.ENTER_FRAME, onMoving);
    }

    /**
     * 停止滚动。
     * @example
     * <listing version="3.0">
     * scroller.stop();
     * </listing>
     */
    public function stop():void {
        _d.removeEventListener(Event.ENTER_FRAME, onMoving);
    }

    /**
     * @private 应用 scrollRect。
     */
    private function updateSC():void {
        _d.scrollRect = new Rectangle(_p.x, _p.y, _size.x, _size.y);
    }

    /**
     * @private 按方向推进并循环。
     */
    private function onMoving(e:Event):void {
        switch (_direction) {
        case 1:
            _p.x += speed;
            if (_p.x > _dsize.x) {
                _p.x = -_size.x;
            }
            break;
        case 2:
            _p.x -= speed;
            if (_p.x < -_size.x) {
                _p.x = _size.x;
            }
            break;
        case 3:
            _p.y += speed;
            if (_p.y > _dsize.y) {
                _p.y = -_d.height;
            }
            break;
        case 4:
            _p.y -= speed;
            if (_p.y < -_d.height) {
                _p.y = _d.height;
            }
            break;
        }

        updateSC();
    }
}
}

