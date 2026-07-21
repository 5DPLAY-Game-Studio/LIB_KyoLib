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
import flash.events.EventDispatcher;

/**
 * 单页加载进度时分派，<code>data</code> 为当前页进度 0–1。
 * @eventType PicPointerEvent.LOAD_PROCESS
 */
[Event(name='LOAD_PROCESS', type='net.play5d.kyo.display.ui.ppt.PicPointerEvent')]
/**
 * 队列全部加载完成时分派。
 * @eventType PicPointerEvent.LOAD_COMPLETE
 */
[Event(name='LOAD_COMPLETE', type='net.play5d.kyo.display.ui.ppt.PicPointerEvent')]
/**
 * 幻灯片页资源队列加载控制器。
 *
 * <p>按顺序调用各 <code>PicLoader.load</code>，成功或失败均继续下一个，并派发进度 / 完成事件。</p>
 *
 * @see PicLoader
 * @see PicPointerEvent
 * @see #loadQueue()
 */
public class PPTLoaderCtrl extends EventDispatcher {
    /**
     * 构造队列加载控制器。
     */
    public function PPTLoaderCtrl() {
    }

    /**
     * 当前正在加载的序号（从 1 起计）。
     * @default 0
     */
    public var curIndex:int;
    /**
     * 队列总长度。
     * @default 0
     */
    public var totalIndex:int;
    /** @private 待加载队列 */
    private var _loaders:Array;

    /**
     * 开始按队列加载。
     * @param loaders <code>PicLoader</code> 数组（会被 <code>shift</code> 消费）。
     * @example
     * <listing version="3.0">
     * ctrl.loadQueue([loader0, loader1]);
     * </listing>
     */
    public function loadQueue(loaders:Array):void {
        _loaders = loaders;

        curIndex   = 0;
        totalIndex = loaders.length;

        loadNext();
    }

    /**
     * @private 取下一个加载；队列空则派发完成。
     */
    private function loadNext():void {
        if (_loaders.length < 1) {
            dispatchEvent(new PicPointerEvent(PicPointerEvent.LOAD_COMPLETE));
            return;
        }

        curIndex++;

        var l:PicLoader = _loaders.shift();
        l.load(loadSuccess, loadFail, loadProcess);
    }

    /**
     * @private 单页成功后继续。
     */
    private function loadSuccess(l:PicLoader):void {
        loadNext();
    }

    /**
     * @private 单页失败后仍继续。
     */
    private function loadFail(l:PicLoader):void {
        loadNext();
    }

    /**
     * @private 转发单页进度。
     */
    private function loadProcess(l:PicLoader, per:Number):void {
        dispatchEvent(new PicPointerEvent(PicPointerEvent.LOAD_PROCESS, per));
    }

}
}
