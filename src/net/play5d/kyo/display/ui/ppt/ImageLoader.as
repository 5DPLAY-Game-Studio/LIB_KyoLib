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
import flash.display.Bitmap;
import flash.display.Loader;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.ProgressEvent;
import flash.geom.Point;
import flash.net.URLRequest;

/**
 * 图片 Loader：支持目标尺寸、成功/失败/进度回调，以及加载失败时是否向外派发错误。
 *
 * @see #loadImage()
 * @see #smooth
 * @see PicLoader
 */
public class ImageLoader extends Loader {
    /**
     * 加载失败时是否 <code>trace</code> URL。
     * @default true
     */
    public static var traceError:Boolean = true;

    /**
     * @param url 可选；非空则立即 <code>loadImage</code>。
     * @param size 目标尺寸；<code>x</code> 或 <code>y</code> 为 0 时按另一边等比缩放。
     * @param back 成功回调，参数为本实例，可选。
     * @param fail 失败回调，参数为本实例，可选。
     * @param process 进度回调，参数为本实例与 0–1 比例，可选。
     */
    public function ImageLoader(
        url    :String = null,
        size   :Point = null,
        back   :Function = null,
        fail   :Function = null,
        process:Function = null
    ) {
        super();
        _size = size;
        if (url) {
            loadImage(url, back, fail, process);
        }
    }

    /**
     * 为 <code>true</code> 时 IO 错误不向外 <code>dispatchEvent</code>（仍会调失败回调）。
     * @default true
     */
    public var mergeError:Boolean = true;
    /**
     * 最近一次加载是否失败。
     * @default false
     */
    public var loadFail:Boolean;
    /** @private */
    private var _size:Point;
    /** @private */
    private var _back:Function;
    /** @private */
    private var _fail:Function;
    /** @private */
    private var _process:Function;
    /** @private */
    private var _url:String;

    /**
     * 当前 / 最近一次加载的 URL。
     * @return URL 字符串。
     * @default null
     */
    public function get url():String {
        return _url;
    }

    /** @private */
    private var _smooth:Boolean;

    /**
     * 位图是否平滑；设置时若已有 Bitmap 内容会立即应用。
     * @return 是否平滑。
     * @default false
     */
    public function get smooth():Boolean {
        return _smooth;
    }

    /** @private */
    public function set smooth(v:Boolean):void {
        _smooth = v;
        if (content) {
            var bp:Bitmap = content as Bitmap;
            if (bp) {
                bp.smoothing = v;
            }
        }
    }

    /**
     * 加载图片；会先卸载并尝试释放旧内容。
     * @param url 资源地址。
     * @param back 成功回调，参数为本实例，可选。
     * @param fail 失败回调，参数为本实例，可选。
     * @param process 进度回调 <code>(loader, per)</code>，可选。
     * @example
     * <listing version="3.0">
     * loader.loadImage('a.jpg', onOk, onFail, onProgress);
     * </listing>
     * @see #unloadAndDispose()
     * @see #reload()
     */
    public function loadImage(url:String, back:Function = null, fail:Function = null, process:Function = null):void {
        unloadAndDispose();
        try {
            this['unloadAndStop'](true);
        }
        catch (e:Error) {
        }

        _url     = url;
        loadFail = false;

        _back    = back;
        _fail    = fail;
        _process = process;

        contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
        contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete);
        contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, onProcess);

        load(new URLRequest(url));
    }

    /**
     * 卸载内容并 dispose 位图数据（若有）。
     * @example
     * <listing version="3.0">
     * loader.unloadAndDispose();
     * </listing>
     */
    public function unloadAndDispose():void {
        if (content) {
            var bp:Bitmap = content as Bitmap;
            unload();
            if (bp) {
                bp.bitmapData.dispose();
            }
        }
    }

    /**
     * 使用当前 <code>url</code> 重新加载。
     * @example
     * <listing version="3.0">
     * loader.reload();
     * </listing>
     * @see #loadImage()
     */
    public function reload():void {
        loadImage(_url);
    }

    /**
     * @private 移除完成 / 错误监听。
     */
    private function removeListener():void {
        contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onIOError);
        contentLoaderInfo.removeEventListener(Event.COMPLETE, onComplete);
    }

    /**
     * @private 完成：按 <code>_size</code> 缩放并回调。
     */
    private function onComplete(e:Event):void {
        if (_size) {
            if (_size.x == 0) {
                height = _size.y;
                scaleX = scaleY;
            }
            else if (_size.y == 0) {
                width  = _size.x;
                scaleY = scaleX;
            }
            else {
                width  = _size.x;
                height = _size.y;
            }
        }

        smooth = _smooth;

        dispatchEvent(e);
        if (_back != null) {
            _back(this);
            _back = null;
        }
        removeListener();
    }

    /**
     * @private 失败：可选 trace / 派发，并调失败回调。
     */
    private function onIOError(e:IOErrorEvent):void {
        if (traceError) {
            trace('load error :', _url);
        }
        loadFail = true;
        if (!mergeError) {
            dispatchEvent(e);
        }
        if (_fail != null) {
            _fail(this);
            _fail = null;
        }
        removeListener();
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
}
}
