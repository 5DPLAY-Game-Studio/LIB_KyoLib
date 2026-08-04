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

package net.play5d.kyo.display.ui.ppt {
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.text.TextField;
import flash.utils.Timer;

import net.play5d.kyo.display.ui.ppt.effect.BasePPTEffect;
import net.play5d.kyo.display.ui.ppt.effect.PPTef_scrollH;
import net.play5d.kyo.utils.KyoColor;

/**
 * 翻页开始时分派，<code>data</code> 为当前页索引。
 * @eventType PicPointerEvent.CHANGE_START
 */
[Event(name='CHANGE_START', type='net.play5d.kyo.display.ui.ppt.PicPointerEvent')]
/**
 * 翻页动画结束时分派，<code>data</code> 为当前页索引。
 * @eventType PicPointerEvent.CHANGE_FINISH
 */
[Event(name='CHANGE_FINISH', type='net.play5d.kyo.display.ui.ppt.PicPointerEvent')]
/**
 * 可视为点击的鼠标抬起时分派，<code>data</code> 为当前页索引。
 * @eventType PicPointerEvent.MOUSE_UP
 */
[Event(name='MOUSE_UP', type='net.play5d.kyo.display.ui.ppt.PicPointerEvent')]
/**
 * 资源加载进度；整体进度为 0–1，写入 <code>data</code>。
 * @eventType PicPointerEvent.LOAD_PROCESS
 */
[Event(name='LOAD_PROCESS', type='net.play5d.kyo.display.ui.ppt.PicPointerEvent')]
/**
 * 全部资源加载完成时分派。
 * @eventType PicPointerEvent.LOAD_COMPLETE
 */
[Event(name='LOAD_COMPLETE', type='net.play5d.kyo.display.ui.ppt.PicPointerEvent')]
/**
 * 滚动图片幻灯片：定时翻页、效果过渡、可选拖拽与加载进度提示。
 *
 * @see PicPointerEvent
 * @see BasePPTEffect
 * @see PPTLoaderCtrl
 * @see #initlize()
 * @see #toNext()
 * @see #toPrev()
 */
public class PicPointer extends Sprite {
    /**
     * @param size 可视区域尺寸。
     * @param delay 自动翻页间隔（秒），默认 1。
     * @param effect 切换效果；为 <code>null</code> 时使用 <code>PPTef_scrollH</code>。
     */
    public function PicPointer(size:Point, delay:Number = 1, effect:BasePPTEffect = null) {
        this.size  = size;
        this.delay = delay;

        scrollRect = new Rectangle(0, 0, size.x, size.y);

        _effect = effect;
        _effect ||= new PPTef_scrollH();

        _picSprite = new Sprite();
        addChild(_picSprite);

        _picSprite.graphics.beginFill(KyoColor.BLACK, 0);
        _picSprite.graphics.drawRect(0, 0, size.x, size.y);
        _picSprite.graphics.endFill();
    }

    /**
     * 可视区域尺寸。
     */
    public var size:Point;
    /**
     * 自动翻页间隔（秒）。
     */
    public var delay:Number;
    /** @private 资源 URL 列表 */
    private var _datas:Array;
    /** @private id → PicLoader */
    private var _loaders:Object;
    /** @private 承载页内容的容器 */
    private var _picSprite:Sprite;
    /** @private 切换效果 */
    private var _effect:BasePPTEffect;
    /** @private 队列加载控制 */
    private var _loaderCtrl:PPTLoaderCtrl = new PPTLoaderCtrl();
    /** @private 加载进度信息文本 */
    private var _infoTxt:TextField;
    /** @private 自动翻页计时器 */
    private var _timer:Timer;
    /** @private 当前页索引；未初始化为 -1 */
    private var _curId:int                = -1;

    /**
     * 当前页索引。
     * @return 页索引；未初始化时为 -1。
     * @default -1
     */
    public function get curId():int {
        return _curId;
    }

    /** @private */
    private var _dragAble:Boolean;

    /**
     * 是否启用拖拽翻页；设为 <code>true</code> 时调用效果的 <code>initDrag</code>。
     * @return 是否可拖拽。
     * @default false
     */
    public function get dragAble():Boolean {
        return _dragAble;
    }

    /** @private */
    public function set dragAble(v:Boolean):void {
        _dragAble = v;
        if (v) {
            _effect.initDrag();
        }
    }

    /** @private */
    public function set showInfo(v:Boolean):void {
        if (v) {
            if (!_infoTxt) {
                _infoTxt              = new TextField();
                _infoTxt.textColor    = KyoColor.WHITE;
                _infoTxt.mouseEnabled = false;
                _infoTxt.width        = size.x;
                _infoTxt.height       = size.y;
                _infoTxt.multiline    = true;
                addChild(_infoTxt);
            }
        }
        else {
            if (_infoTxt) {
                try {
                    removeChild(_infoTxt);
                }
                catch (e:*) {
                }
                _infoTxt = null;
            }
        }
    }

    /**
     * 写入进度信息文本（需先 <code>showInfo = true</code>）。
     * @param v 显示文案。
     * @example
     * <listing version="3.0">
     * pointer.showInfo = true;
     * pointer.infoMsg('loading...');
     * </listing>
     */
    public function infoMsg(v:String):void {
        if (_infoTxt) {
            _infoTxt.text = v;
        }
    }

    /**
     * 初始化幻灯：绑定效果、加载数据并启动自动翻页。
     * @param data 图片 / 资源 URL 数组。
     * @example
     * <listing version="3.0">
     * pointer.initlize(['a.jpg', 'b.jpg']);
     * </listing>
     * @see #update()
     */
    public function initlize(data:Array):void {
        _effect.initlize(this, _picSprite);

        setData(data);
        _curId = 0;
        resetLoaders();
        addEventListener(MouseEvent.MOUSE_UP, onClick);
        initTimer();

        dispatchEvent(new PicPointerEvent(PicPointerEvent.CHANGE_START, _curId));
    }

    /**
     * 用新数据重建幻灯（先 <code>destroy</code> 再加载）。
     * @param data 资源 URL 数组。
     * @see #initlize()
     * @see #destroy()
     */
    public function update(data:Array):void {
        destroy();
        setData(data);
        _curId = 0;
        initTimer();
        resetLoaders();
        dispatchEvent(new PicPointerEvent(PicPointerEvent.CHANGE_START, _curId));
    }

    /**
     * 销毁页加载器并从容器移除。
     * @example
     * <listing version="3.0">
     * pointer.destroy();
     * </listing>
     */
    public function destroy():void {
        _curId = -1;

        if (_loaders) {
            for each(var p:PicLoader in _loaders) {
                try {
                    _picSprite.removeChild(p);
                }
                catch (e:Error) {
                }
                p.destroy();
            }
            _loaders = null;
        }

    }

    /**
     * 暂停自动翻页计时器。
     * @example
     * <listing version="3.0">
     * pointer.pause();
     * </listing>
     * @see #resume()
     */
    public function pause():void {
        if (_timer) {
            _timer.stop();
        }
    }

    /**
     * 重置并启动自动翻页计时器。
     * @see #pause()
     */
    public function resume():void {
        if (_timer) {
            _timer.reset();
            _timer.start();
        }
    }

    /**
     * 切换到下一页并播放过渡动画。
     * @example
     * <listing version="3.0">
     * pointer.toNext();
     * </listing>
     * @see #toPrev()
     * @see #jump()
     */
    public function toNext():void {
        pause();
        _curId = fixid(_curId + 1);
        dispatchEvent(new PicPointerEvent(PicPointerEvent.CHANGE_START, _curId));
        _effect.tweenNext(tweenFinish);
    }

    /**
     * 切换到上一页并播放过渡动画。
     * @see #toNext()
     */
    public function toPrev():void {
        pause();
        _curId = fixid(_curId - 1);
        dispatchEvent(new PicPointerEvent(PicPointerEvent.CHANGE_START, _curId));
        _effect.tweenPrev(tweenFinish);
    }

    /**
     * 跳转到指定页（内部先定位到上一页再 <code>toNext</code> 以走过渡）。
     * @param id 目标页索引。
     * @example
     * <listing version="3.0">
     * pointer.jump(2);
     * </listing>
     */
    public function jump(id:int):void {
        if (id == _curId) {
            return;
        }

        _curId = fixid(id - 1);
        resetLoaders();

        toNext();
    }

    /**
     * @private 按 URL 列表创建加载器并开始队列加载。
     */
    private function setData(v:Array):void {
        _loaders            = {};
        var needLoads:Array = [];
        for (var i:int; i < v.length; i++) {
            var url:String   = v[i];
            var pl:PicLoader = new PicLoader(size, url);
            pl.id            = i;
            _loaders[pl.id]  = pl;
            needLoads.push(pl);
        }
        _datas = v;

        _loaderCtrl.addEventListener(PicPointerEvent.LOAD_PROCESS, onLoadProcess);
        _loaderCtrl.addEventListener(PicPointerEvent.LOAD_COMPLETE, onLoadComplete);
        _loaderCtrl.loadQueue(needLoads);
    }

    /**
     * @private 多页时创建计时器；单页则销毁计时器。
     */
    private function initTimer():void {
        if (_datas.length > 1) {
            if (!_timer) {
                _timer = new Timer(delay * 1000, 1);
                _timer.addEventListener(TimerEvent.TIMER_COMPLETE, onTimer);
            }
        }
        else {
            if (_timer) {
                _timer.stop();
                _timer.removeEventListener(TimerEvent.TIMER_COMPLETE, onTimer);
                _timer = null;
            }
        }

        resume();
    }

    /**
     * @private 将索引环绕到合法范围。
     */
    private function fixid(id:int):int {
        if (id > _datas.length - 1) {
            id = 0;
        }
        if (id < 0) {
            id = _datas.length - 1;
        }
        return id;
    }

    /**
     * @private 过渡结束：重排三页并恢复计时。
     */
    private function tweenFinish():void {
        resetLoaders();
        resume();
        dispatchEvent(new PicPointerEvent(PicPointerEvent.CHANGE_FINISH, _curId));
    }

    /**
     * @private 按当前索引布置当前 / 下一 / 上一页到效果与容器。
     */
    private function resetLoaders():void {
        if (!_loaders) {
            return;
        }

        var curLoader:PicLoader  = _loaders[fixid(_curId)];
        var nextLoader:PicLoader = _loaders[fixid(_curId + 1)];
        var prevLoader:PicLoader = _loaders[fixid(_curId - 1)];

        _effect.setPics(curLoader, nextLoader, prevLoader);

        while (_picSprite.numChildren > 0) {
            _picSprite.removeChildAt(0);
        }

        _picSprite.addChild(curLoader);
        _picSprite.addChild(nextLoader);
        _picSprite.addChild(prevLoader);
    }

    /**
     * @private 汇总加载进度并转发事件。
     */
    private function onLoadProcess(e:PicPointerEvent):void {
        var per:Number        = Number(e.data);
        var percentStr:String = int(per * 100) + '%';
        infoMsg('正在加载资源：' + percentStr + ' (' + _loaderCtrl.curIndex + '/' + _loaderCtrl.totalIndex + ')');

        var allProcess:Number = (_loaderCtrl.curIndex - 1 + per) / _loaderCtrl.totalIndex;
        this.dispatchEvent(new PicPointerEvent(PicPointerEvent.LOAD_PROCESS, allProcess));
    }

    /**
     * @private 全部加载完成。
     */
    private function onLoadComplete(e:PicPointerEvent):void {
        showInfo = false;
        this.dispatchEvent(new PicPointerEvent(PicPointerEvent.LOAD_COMPLETE));
    }

    /**
     * @private 点击抬起（排除拖拽）时派发 MOUSE_UP。
     */
    private function onClick(e:MouseEvent):void {
        if (!_effect.canClick()) {
            return;
        }
        dispatchEvent(new PicPointerEvent(PicPointerEvent.MOUSE_UP, _curId));
    }

    /**
     * @private 计时到点翻到下一页。
     */
    private function onTimer(e:TimerEvent):void {
        toNext();
    }

}
}
