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
import flash.display.Loader;
import flash.display.LoaderInfo;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.ProgressEvent;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.net.URLRequest;

import mx.rpc.events.FaultEvent;

/**
 * SWF 加载显示容器：按目标尺寸缩放，并支持成功 / 失败 / 进度回调。
 *
 * @see net.play5d.kyo.loader.ImageLoader
 * @see PicLoader
 * @see #loadSwf()
 * @see #unload()
 */
public class SwfLoader extends Sprite {
    /**
     * @param url 可选；非空则立即加载。
     * @param size 显示区域尺寸（同时作为 <code>scrollRect</code>）。
     * @param back 成功无参回调，可选。
     * @param fail 失败无参回调，可选。
     * @param progress 进度回调 <code>(loader, per)</code>，可选。
     */
    public function SwfLoader(
        url     :String = null,
        size    :Point = null,
        back    :Function = null,
        fail    :Function = null,
        progress:Function = null
    ) {
        super();

        _loader = new Loader();
        _loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadSwfComplete);
        _loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
        _loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, onProgress);
        _loader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
        _loader.addEventListener(FaultEvent.FAULT, faultErrorHandler);
        addChild(_loader);

        _size = size;
        if (_size) {
            this.scrollRect = new Rectangle(0, 0, _size.x, _size.y);
        }
        if (url != null) {
            loadSwf(url, back, fail, progress);
        }
    }

    /** @private */
    private var _size:Point;
    /** @private */
    private var _loader:Loader;
    /** @private */
    private var _loadBack:Function;
    /** @private */
    private var _failBack:Function;
    /** @private */
    private var _progressBack:Function;

    /**
     * 加载 SWF。
     * @param url 资源地址。
     * @param back 成功无参回调，可选。
     * @param fail 失败无参回调，可选。
     * @param progress 进度回调 <code>(loader, per)</code>，可选。
     * @example
     * <listing version="3.0">
     * swf.loadSwf('page.swf', onOk, onFail);
     * </listing>
     * @see #unload()
     */
    public function loadSwf(
        url     :String,
        back    :Function = null,
        fail    :Function = null,
        progress:Function = null
    ):void {
        _loadBack     = back;
        _failBack     = fail;
        _progressBack = progress;

        _loader.load(new URLRequest(url));
    }

    /**
     * 卸载 SWF 并停止其内容。
     * @example
     * <listing version="3.0">
     * swf.unload();
     * </listing>
     */
    public function unload():void {
        if (_loader) {
            _loader.unloadAndStop(true);
        }
    }

    /**
     * @private IO 错误回调。
     */
    private function ioErrorHandler(event:IOErrorEvent):void {
        trace('SwfLoader:ioErrorHandler : ' + event);
        invokeFail();
    }

    /**
     * @private Fault 错误回调。
     */
    private function faultErrorHandler(event:FaultEvent):void {
        trace('SwfLoader:faultErrorHandler : ' + event);
        invokeFail();
    }

    /**
     * @private 调用失败回调一次。
     */
    private function invokeFail():void {
        if (_failBack != null) {
            _failBack();
            _failBack = null;
        }
    }

    /**
     * @private 进度回调。
     */
    private function onProgress(e:ProgressEvent):void {
        if (_progressBack != null) {
            _progressBack(this, e.bytesLoaded / e.bytesTotal);
        }
    }

    /**
     * @private 加载完成：按 <code>_size</code> 缩放并回调。
     */
    private function loadSwfComplete(e:Event):void {
        var info:LoaderInfo = e.currentTarget as LoaderInfo;

        if (_size) {
            _loader.scaleX = _size.x / info.width;
            _loader.scaleY = _size.y / info.height;
        }

        if (_loadBack != null) {
            _loadBack();
            _loadBack = null;
        }
    }

}
}