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

import flash.display.Loader;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.net.URLRequest;
import flash.utils.Timer;

/**
 * 开始滚动切换时分派，<code>data</code> 为当前页索引。
 * @eventType PicScrollEvent.CHANGE
 */
[Event(name='CHANGE', type='net.play5d.kyo.display.ui.PicScrollEvent')]
/**
 * 当前页滚动到位时分派，<code>data</code> 为当前页索引。
 * @eventType PicScrollEvent.CHANGE_COMPLETE
 */
[Event(name='CHANGE_COMPLETE', type='net.play5d.kyo.display.ui.PicScrollEvent')]
/**
 * 可视为点击的鼠标抬起时分派，<code>data</code> 为当前页索引。
 * @eventType PicScrollEvent.MOUSE_UP
 */
[Event(name='MOUSE_UP', type='net.play5d.kyo.display.ui.PicScrollEvent')]
/**
 * 滚动图片幻灯：按 URL 列表自动轮播，支持方向、缩放与拖拽。
 *
 * @see PicScrollEvent
 * @see #initialize()
 * @see #update()
 * @see #destroy()
 */
public class PicScroller extends Sprite {
    /**
     * @param size 可视区域尺寸。
     * @param speed 滚动速度，默认 1。
     * @param delay 停留间隔（秒），默认 1。
     */
    public function PicScroller(size:Point, speed:Number = 1, delay:Number = 1) {
        this.speed = speed;
        this.size  = size;
        this.delay = delay;

        scrollRect = new Rectangle(0, 0, size.x, size.y);

        _sp = new Sprite();
        addChild(_sp);
    }

    /**
     * 可视区域尺寸。
     */
    public var size:Point;
    /**
     * 滚动速度。
     */
    public var speed:Number;
    /**
     * 每页停留间隔（秒）。
     */
    public var delay:Number;
    /**
     * 移动方向（1：从左向右，2：从右向左，3：从上向下，4：从下向上）。
     * @default 4
     */
    public var direct:int          = 4;
    /**
     * 是否锁定图片宽度为可视宽度。
     * @default true
     */
    public var lockWidth:Boolean   = true;
    /**
     * 是否锁定图片高度为可视高度。
     * @default false
     */
    public var lockHeight:Boolean  = false;
    /**
     * 是否允许在自动滚动过程中拖动。
     * @default false
     */
    public var movingTouch:Boolean = false;
    /**
     * 是否在切换前预加载相邻页。
     * @default true
     */
    public var showNear:Boolean    = true;
    /** @private 资源 URL 列表 */
    private var _datas:Array;
    /** @private 当前页 Loader */
    private var _loader:Loader;
    /** @private 当前滚动方向 */
    private var _direct:int;
    /** @private 承载页内容的容器 */
    private var _sp:Sprite;
    /** @private 相邻页 Loader */
    private var _nearLoader:Loader;
    /** @private 是否正在滚动 */
    private var _moving:Boolean;
    /** @private 当前页是否已到位 */
    private var _reached:Boolean;
    /** @private 停留计时器 */
    private var _timer:Timer;
    /** @private 是否正在补间对齐 */
    private var _tweening:Boolean;
    /** @private 按下时的鼠标偏移 */
    private var _downP:Point;
    /** @private 是否处于拖动状态 */
    private var _dragging:Boolean;
    /** @private 当前页索引；未初始化为 -1 */
    private var _curId:int         = -1;

    /**
     * 当前页索引。
     * @return 页索引；未初始化时为 -1。
     * @default -1
     */
    public function get curId():int {
        return _curId;
    }

    /** @private */
    private var _dragEnabled:Boolean;

    /**
     * 是否允许拖动翻页。
     * @return <code>true</code> 表示可拖动。
     * @default false
     */
    public function get dragEnabled():Boolean {
        return _dragEnabled;
    }

    /** @private */
    public function set dragEnabled(v:Boolean):void {
        _dragEnabled = v;
        if (v) {
            removeEventListener(MouseEvent.MOUSE_DOWN, dragDown);
            addEventListener(MouseEvent.MOUSE_DOWN, dragDown);
        }
    }

    /**
     * 初始化并开始加载首屏。
     * @param data 图片 URL 数组。
     * @example
     * <listing version="3.0">
     * scroller.initialize(['a.jpg', 'b.jpg']);
     * </listing>
     */
    public function initialize(data:Array):void {
        _datas  = data;
        _direct = direct;
        loadNext();

        addEventListener(MouseEvent.MOUSE_UP, onClick);
    }

    /**
     * 重置数据并重新加载。
     * @param data 新的图片 URL 数组。
     * @example
     * <listing version="3.0">
     * scroller.update(['c.jpg']);
     * </listing>
     */
    public function update(data:Array):void {
        destroy();
        _datas  = data;
        _direct = direct;
        loadNext();
    }

    /**
     * 停止轮播并卸载当前页。
     * @example
     * <listing version="3.0">
     * scroller.destroy();
     * </listing>
     */
    public function destroy():void {
        _curId = -1;
        pause();
        if (_loader) {
            _loader.unload();
            _loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, loadComplete);
            _loader = null;
        }
    }

    /** @private 加载下一页 */
    private function loadNext():void {
        _curId++;
        _curId = wrapIndex(_curId);

        if (_loader) {
            _loader.unload();
        }
        else {
            _loader = new Loader();
        }

        _loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadComplete);
        _loader.load(new URLRequest(_datas[_curId]));
        _sp.addChild(_loader);
    }

    /** @private 将索引限制在有效范围 */
    private function wrapIndex(id:int):int {
        if (id > _datas.length - 1) {
            id = 0;
        }
        if (id < 0) {
            id = _datas.length - 1;
        }

        return id;
    }

    /** @private 预加载相邻页 */
    private function loadNear():void {
        _nearLoader = new Loader();
        _nearLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadNearComplete);

        var nid:int = wrapIndex(_curId + 1);
        _nearLoader.load(new URLRequest(_datas[nid]));

        switch (_direct) {
        case 1:
            break;
        case 2:
            break;
        case 3:
            break;
        case 4:
            _nearLoader.x = 0;
            _nearLoader.y = _loader.height;
            break;
        }
        _sp.addChild(_nearLoader);
    }

    /** @private 按锁定规则缩放图片 */
    private function formatPic(l:Loader):void {
        if (lockWidth && lockHeight) {
            l.width  = size.x;
            l.height = size.y;
            return;
        }

        if (lockWidth) {
            l.width  = size.x;
            l.scaleY = _loader.scaleX;
        }

        if (lockHeight) {
            l.height = size.y;
            l.scaleX = _loader.scaleY;
        }
    }

    /** @private 开始滚动并派发 CHANGE */
    private function startMove():void {
        dispatchEvent(new PicScrollEvent(PicScrollEvent.CHANGE, _curId));

        initStartPos();

        resume();
        _reached = false;
    }

    /** @private 暂停滚动与计时 */
    private function pause():void {
        removeEventListener(Event.ENTER_FRAME, onMoving);
        _moving = false;
        if (_timer) {
            _timer.stop();
        }
    }

    /** @private 恢复滚动与计时 */
    private function resume():void {
        removeEventListener(Event.ENTER_FRAME, onMoving);
        addEventListener(Event.ENTER_FRAME, onMoving);

        _moving = true;

        if (_timer) {
            _timer.reset();
            _timer.start();
        }
    }

    /** @private 按剩余距离计算本帧速度 */
    private function getSpd():Number {
        var pos:Number;
        var span:Number;
        switch (_direct) {
        case 1:
        case 2:
            pos  = _sp.x;
            span = _loader.width - size.x;
            break;
        case 3:
        case 4:
            pos  = _sp.y;
            span = _loader.height - size.y;
            break;
        }

        var over:Number    = Math.abs(pos) - Math.abs(span);
        var overAbs:Number = Math.abs(over);
        var spd:Number;

        if (pos > 0) {
            spd = pos * 0.1;
        }
        else if (over > 0) {
            spd = overAbs * 0.1;
            if (overAbs > _loader.height / 1.6) {
                spd = 1;
            }
        }
        else {
            spd = speed;
        }

        if (spd < speed) {
            spd = speed;
        }

        return spd;
    }

    /** @private 按方向移动容器 */
    private function move():void {
        var spd:Number = getSpd();

        switch (_direct) {
        case 1:
            _sp.x += spd;
            break;
        case 2:
            _sp.x -= spd;
            break;
        case 3:
            _sp.y += spd;
            break;
        case 4:
            _sp.y -= spd;
            break;
        }
    }

    /** @private 设置滚动起始位置 */
    private function initStartPos():void {
        if (showNear) {
            switch (_direct) {
            case 1:
            case 2:
                _sp.x = 0;
                break;
            case 3:
            case 4:
                _sp.y = 0;
                break;
            }
            return;
        }

        switch (_direct) {
        case 1:
            _sp.x = -_loader.width;
            break;
        case 2:
            _sp.x = size.x;
            break;
        case 3:
            _sp.y = -_loader.height;
            break;
        case 4:
            _sp.y = size.y;
            break;
        }
    }

    /** @private 是否已滚出可视区 */
    private function checkOver():Boolean {
        switch (_direct) {
        case 1:
            return _sp.x > size.x;
        case 2:
            return _sp.x < -_loader.width;
        case 3:
            return _sp.y > size.y;
        case 4:
            return _sp.y < -_loader.height;
        }

        return false;
    }

    /** @private 检测是否到达目标位置 */
    private function checkReach():void {
        if (_reached) {
            return;
        }
        var b:Boolean;
        switch (_direct) {
        case 1:
            b = _sp.x >= 0;
            break;
        case 2:
            b = _sp.x <= -(_loader.width - size.x);
            break;
        case 3:
            b = _sp.y >= 0;
            break;
        case 4:
            b = _sp.y <= -(_loader.height - size.y);
            break;
        }
        if (b) {
            reach();
        }
    }

    /** @private 对齐到位并派发 CHANGE_COMPLETE */
    private function reach():void {
        pause();
        var k:String;
        var v:Number;
        switch (_direct) {
        case 1:
            k = 'x';
            v = 0;
            break;
        case 2:
            k = 'x';
            v = -(_loader.width - size.x);
            break;
        case 3:
            k = 'y';
            v = 0;
            break;
        case 4:
            k = 'y';
            v = -(_loader.height - size.y);
            break;
        }
        if (Math.abs(_sp[k] - v) > 10) {
            _tweening       = true;
            var o:Object    = {};
            o[k]            = v;
            o['onComplete'] = function ():void {
                _tweening = false;
            };
            TweenLite.to(_sp, 0.5, o);
        }

        _reached = true;
        dispatchEvent(new PicScrollEvent(PicScrollEvent.CHANGE_COMPLETE, _curId));
        newTimer();

        _direct = direct;
    }

    /** @private 启动停留计时器 */
    private function newTimer():void {
        removeTimer();
        _timer = new Timer(delay * 1000, 1);
        _timer.addEventListener(TimerEvent.TIMER_COMPLETE, reachComplete);
        _timer.start();
    }

    /** @private 移除停留计时器 */
    private function removeTimer():void {
        if (_timer) {
            _timer.removeEventListener(TimerEvent.TIMER_COMPLETE, reachComplete);
            _timer = null;
        }
    }

    /** @private 点击检测并派发 MOUSE_UP */
    private function onClick(e:MouseEvent):void {
        if (_dragging) {
            return;
        }

        if (_downP) {
            if (Math.abs(mouseX - _downP.x) + Math.abs(mouseY - _downP.y) > 20) {
                return;
            }
        }

        dispatchEvent(new PicScrollEvent(PicScrollEvent.MOUSE_UP, _curId));
    }

    /** @private 当前页加载完成 */
    private function loadComplete(e:Event):void {
        _loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, loadComplete);
        formatPic(_loader);

        if (showNear) {
            loadNear();
        }
        else {
            startMove();
        }
    }

    /** @private 相邻页加载完成 */
    private function loadNearComplete(e:Event):void {
        _nearLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, loadNearComplete);
        formatPic(_nearLoader);
        startMove();
    }

    /** @private 每帧滚动逻辑 */
    private function onMoving(e:Event):void {
        move();
        if (checkOver()) {
            pause();
            loadNext();
            return;
        }
        checkReach();
    }

    /** @private 停留结束，继续滚动 */
    private function reachComplete(e:TimerEvent):void {
        removeTimer();
        resume();
    }

    /** @private 按下开始拖动 */
    private function dragDown(e:MouseEvent):void {
        _downP = new Point(mouseX - _sp.x, mouseY - _sp.y);

        if (!movingTouch && _moving) {
            return;
        }
        if (_tweening) {
            return;
        }

        if (stage) {
            stage.addEventListener(MouseEvent.MOUSE_UP, dragUp);
        }
        else {
            addEventListener(MouseEvent.MOUSE_UP, dragUp);
        }

        removeEventListener(Event.ENTER_FRAME, onDragging);
        addEventListener(Event.ENTER_FRAME, onDragging);

        pause();
    }

    /** @private 拖动中更新位置 */
    private function onDragging(e:Event):void {
        switch (direct) {
        case 1:
        case 2:
            _dragging ||= Math.abs(mouseX - _downP.x) > 10;
            if (_dragging) {
                _sp.x = mouseX - _downP.x;
            }
            break;
        case 3:
        case 4:
            _dragging ||= Math.abs(mouseY - _downP.y) > 10;
            if (_dragging) {
                _sp.y = mouseY - _downP.y;
            }
            break;
        }
    }

    /** @private 抬起结束拖动并判定翻页 */
    private function dragUp(e:MouseEvent):void {
        stage.removeEventListener(MouseEvent.MOUSE_UP, dragUp);
        removeEventListener(MouseEvent.MOUSE_UP, dragUp);

        removeEventListener(Event.ENTER_FRAME, onDragging);

        if (!_dragging) {
            return;
        }

        _dragging = false;

        switch (_direct) {
        case 1:
            if (_sp.x < -_loader.width / 4) {
                _direct  = 2;
                _curId -= 2;
                _reached = true;
            }
            break;
        case 2:
            if (_sp.x > _loader.width / 4) {
                _direct  = 1;
                _curId -= 2;
                _reached = true;
            }
            break;
        case 3:
            if (_sp.y < -_loader.height / 4) {
                _direct  = 4;
                _curId -= 2;
                _reached = true;
            }
            break;
        case 4:
            if (_sp.y > _loader.height / 4) {
                _direct  = 3;
                _curId -= 2;
                _reached = true;
            }
            break;
        }

        resume();
    }

}
}
