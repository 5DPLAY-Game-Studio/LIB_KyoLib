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
 * @see ImageLoader
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
     * @param process 进度回调 <code>(loader, per)</code>，可选。
     */
    public function SwfLoader(
        url    :String = null,
        size   :Point = null,
        back   :Function = null,
        fail   :Function = null,
        process:Function = null
    ) {
        super();

        _loader = new Loader();
        _loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadSwfComplete);
        _loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, IOErrorHandler);
        _loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, onProcess);
        _loader.addEventListener(IOErrorEvent.IO_ERROR, IOErrorHandler);
        _loader.addEventListener(FaultEvent.FAULT, fatalErrorHandler);
        addChild(_loader);

        _size           = size;
        this.scrollRect = new Rectangle(0, 0, _size.x, _size.y);
        if (url != null) {
            loadSwf(url, back, fail, process);
        }
    }

    /** @private */
    private var _size:Point;
    /** @private SWF 原始宽 */
    private var _swfWidth:Number = 0;
    /** @private SWF 原始高 */
    private var _swfHeight:Number = 0;
    /** @private */
    private var _loader:Loader;
    /** @private */
    private var _loadBack:Function;
    /** @private */
    private var _failBack:Function;
    /** @private */
    private var _process:Function;

    /**
     * 加载 SWF。
     * @param url 资源地址。
     * @param back 成功无参回调，可选。
     * @param fail 失败无参回调，可选。
     * @param process 进度回调 <code>(loader, per)</code>，可选。
     * @example
     * <listing version="3.0">
     * swf.loadSwf('page.swf', onOk, onFail);
     * </listing>
     * @see #unload()
     */
    public function loadSwf(url:String, back:Function = null, fail:Function = null, process:Function = null):void {
        _loadBack = back;
        _failBack = fail;
        _process  = process;

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
    private function IOErrorHandler(event:IOErrorEvent):void {
        trace('SWFLoader:IOErrorHandler : ' + event);
        if (_failBack != null) {
            _failBack();
            _failBack = null;
        }
    }

    /**
     * @private Fault 错误回调。
     */
    private function fatalErrorHandler(event:FaultEvent):void {
        trace('SWFLoader:fatalErrorHandler : ' + event);
        if (_failBack != null) {
            _failBack();
            _failBack = null;
        }
    }

    /**
     * @private 进度回调。
     */
    private function onProcess(e:ProgressEvent):void {
        if (_process != null) {
            var per:Number = e.bytesLoaded / e.bytesTotal;
            _process(this, per);
        }
    }

    /**
     * @private 加载完成：按 <code>_size</code> 缩放并回调。
     */
    private function loadSwfComplete(e:Event):void {
        var loaderinfo:LoaderInfo = e.currentTarget as LoaderInfo;
        _swfWidth                 = loaderinfo.width;
        _swfHeight                = loaderinfo.height;

        if (_size) {
            _loader.scaleX = _size.x / _swfWidth;
            _loader.scaleY = _size.y / _swfHeight;
        }

        if (_loadBack != null) {
            _loadBack();
            _loadBack = null;
        }
    }

}
}
