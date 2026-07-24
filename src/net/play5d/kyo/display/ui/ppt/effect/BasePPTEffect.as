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

package net.play5d.kyo.display.ui.ppt.effect {
import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;

import net.play5d.kyo.display.ui.ppt.PicPointer;

/**
 * PPT / 幻灯片切换效果基类。
 *
 * <p>负责绑定 <code>PicPointer</code>、管理当前/上一/下一页显示对象，以及可选的拖拽翻页流程；具体过渡由子类实现。</p>
 *
 * @see PPTef_alpha
 * @see PPTef_scrollH
 * @see PPTef_scrollV
 * @see net.play5d.kyo.display.ui.ppt.PicPointer
 */
public class BasePPTEffect {
    /**
     * 构造效果实例。
     */
    public function BasePPTEffect() {
    }

    /**
     * 是否启用拖拽翻页。
     * @default false
     */
    public var drag:Boolean;
    /**
     * 当前是否处于拖拽中。
     * @default false
     */
    public var draging:Boolean;
    /**
     * 过渡动画时长（秒）。
     * @default 1
     */
    public var duration:Number = 1;
    /** @private 所属翻页控制器 */
    protected var _pointer:PicPointer;
    /** @private 页面尺寸副本 */
    protected var _size:Point;
    /** @private 承载当前/邻页的容器 */
    protected var _sp:Sprite;
    /** @private 当前页 */
    protected var _currentPic:DisplayObject;
    /** @private 上一页 */
    protected var _prevPic:DisplayObject;
    /** @private 下一页 */
    protected var _nextPic:DisplayObject;
    /** @private 按下时相对容器的鼠标点 */
    protected var _downP:Point;
    /** @private 按下时容器坐标 */
    protected var _downSPP:Point;

    /**
     * 绑定翻页控制器与内容容器。
     * @param v 翻页控制器。
     * @param sp 内容容器。
     * @example
     * <listing version="3.0">
     * effect.initlize(pointer, contentSp);
     * </listing>
     */
    public final function initlize(v:PicPointer, sp:Sprite):void {
        _pointer = v;
        _size    = _pointer.size.clone();
        _sp      = sp;
    }

    /**
     * 判断本次按下是否可视为点击（位移小于 20）。
     * @return <code>true</code> 表示可点击；无按下点时也返回 <code>true</code>。
     * @example
     * <listing version="3.0">
     * if (effect.canClick()) {
     *     handleClick();
     * }
     * </listing>
     */
    public final function canClick():Boolean {
        if (_downP) {
            var jl:Number = Math.abs(_pointer.mouseX - _downP.x) + Math.abs(_pointer.mouseY - _downP.y);
            return jl < 20;
        }
        return true;
    }

    /**
     * 移除拖拽相关监听并断开引用。
     * @example
     * <listing version="3.0">
     * effect.destroy();
     * </listing>
     */
    public function destroy():void {
        if (_sp) {
            _sp.removeEventListener(MouseEvent.MOUSE_DOWN, dragDown);
            _sp = null;
        }
        if (_pointer) {
            _pointer.removeEventListener(Event.ENTER_FRAME, drag_enterframe);
            if (_pointer.stage) {
                _pointer.stage.removeEventListener(MouseEvent.MOUSE_UP, dragUp);
            }
            _pointer.removeEventListener(MouseEvent.MOUSE_UP, dragUp);
            _pointer.removeEventListener(Event.ENTER_FRAME, drag_enterframe);
        }
    }

    /**
     * 一次性设置当前、下一、上一页并调用 <code>initStart</code>。
     * @param cur 当前页。
     * @param next 下一页。
     * @param prev 上一页。
     * @see #setCurrent()
     * @see #setNext()
     * @see #setPrev()
     */
    public function setPics(cur:DisplayObject, next:DisplayObject, prev:DisplayObject):void {
        _currentPic = cur;
        _nextPic    = next;
        _prevPic    = prev;
        initStart();
    }

    /**
     * 设置当前页并刷新起始布局。
     * @param v 当前页显示对象。
     */
    public final function setCurrent(v:DisplayObject):void {
        _currentPic = v;
        initStart();
    }

    /**
     * 设置下一页并刷新起始布局。
     * @param v 下一页显示对象。
     */
    public final function setNext(v:DisplayObject):void {
        _nextPic = v;
        initStart();
    }

    /**
     * 设置上一页并刷新起始布局。
     * @param v 上一页显示对象。
     */
    public final function setPrev(v:DisplayObject):void {
        _prevPic = v;
        initStart();
    }

    /**
     * 过渡到下一页；子类实现具体动画。
     * @param back 完成回调。
     */
    public function tweenNext(back:Function):void {
    }

    /**
     * 过渡到上一页；子类实现具体动画。
     * @param back 完成回调。
     */
    public function tweenPrev(back:Function):void {
    }

    /**
     * 拖拽未达翻页阈值时回弹；子类实现。
     */
    public function tweenBack():void {
    }

    /**
     * 是否正在过渡动画中。
     * @return 基类恒为 <code>false</code>；子类按 Tween 状态返回。
     */
    public function tweening():Boolean {
        return false;
    }

    /**
     * 停止当前过渡；子类实现。
     */
    public function tweenStop():void {
    }

    /**
     * 在内容容器上注册拖拽按下监听。
     * @example
     * <listing version="3.0">
     * effect.initDrag();
     * </listing>
     */
    public final function initDrag():void {
        _sp.removeEventListener(MouseEvent.MOUSE_DOWN, dragDown);
        _sp.addEventListener(MouseEvent.MOUSE_DOWN, dragDown);
    }

    /**
     * @private 子类在图片就绪后布置初始位置/透明度等。
     */
    protected function initStart():void {
    }

    /**
     * @private 拖拽过程中每帧调用（已确认在拖拽中）。
     */
    protected function onDraging():void {
    }

    /**
     * @private 松手时是否应翻到下一页。
     */
    protected function dragNext():Boolean {
        return false;
    }

    /**
     * @private 松手时是否应翻到上一页。
     */
    protected function dragPrev():Boolean {
        return false;
    }

    /**
     * @private 相对 <code>_pointer</code> 的当前鼠标点。
     */
    protected final function mousePoint():Point {
        return new Point(_pointer.mouseX, _pointer.mouseY);
    }

    /**
     * @private 开始拖拽：记录起点、暂停自动播放并监听移动/抬起。
     */
    private final function dragDown(e:MouseEvent):void {
        _downP   = new Point(_pointer.mouseX - _sp.x, _pointer.mouseY - _sp.y);
        _downSPP = new Point(_sp.x, _sp.y);

        if (tweening()) {
            return;
        }

        if (_pointer.stage) {
            _pointer.stage.addEventListener(MouseEvent.MOUSE_UP, dragUp);
        }
        else {
            _pointer.addEventListener(MouseEvent.MOUSE_UP, dragUp);
        }

        _pointer.removeEventListener(Event.ENTER_FRAME, drag_enterframe);
        _pointer.addEventListener(Event.ENTER_FRAME, drag_enterframe);

        _pointer.pause();
    }

    /**
     * @private 拖拽中判定位移并回调 <code>onDraging</code>。
     */
    private function drag_enterframe(e:Event):void {
        draging ||= Math.abs(_pointer.mouseX - _downP.x) > 10 || Math.abs(_pointer.mouseY - _downP.y) > 10;
        if (draging) {
            onDraging();
        }
    }

    /**
     * @private 松手：按位移决定翻页或回弹。
     */
    private function dragUp(e:MouseEvent):void {
        if (_pointer.stage) {
            _pointer.stage.removeEventListener(MouseEvent.MOUSE_UP, dragUp);
        }

        _pointer.removeEventListener(MouseEvent.MOUSE_UP, dragUp);

        _pointer.removeEventListener(Event.ENTER_FRAME, drag_enterframe);

        if (!draging) {
            return;
        }
        draging = false;

        if (dragNext()) {
            _pointer.toNext();
            return;
        }
        if (dragPrev()) {
            _pointer.toPrev();
            return;
        }
        tweenBack();
    }

}
}
