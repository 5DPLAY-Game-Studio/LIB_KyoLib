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

package net.play5d.kyo.loader {
import flash.display.Bitmap;
import flash.display.Loader;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.ProgressEvent;
import flash.geom.Point;
import flash.net.URLRequest;

/**
 * 继承 <code>Loader</code> 的图片加载器，支持目标尺寸、平滑、进度与成功 / 失败回调。
 *
 * @see #loadImage()
 * @see BitmapLoader
 */
public class ImageLoader extends Loader {
    /**
     * 为 <code>true</code> 时 IO 错误会 <code>trace</code> URL。
     * @default true
     */
    public static var traceError:Boolean = true;

    /**
     * @param url 可选，非空则立即 <code>loadImage</code>。
     * @param size 目标尺寸；<code>x</code> 或 <code>y</code> 为 0 时按比例缩放。
     * @param back 成功回调，参数为本实例。
     * @param fail 失败回调，参数为本实例。
     * @param process 进度回调，参数为本实例与 0–1 比例；可省略。
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
     * 为 <code>true</code> 时不向外派发 <code>IOErrorEvent</code>（仍调用 fail 回调）。
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
     * 当前加载 URL。
     */
    public function get url():String {
        return _url;
    }

    /** @private */
    private var _smooth:Boolean;

    /**
     * 位图是否平滑；内容为 Bitmap 时同步到 <code>smoothing</code>。
     * @default false
     */
    public function get smooth():Boolean {
        return _smooth;
    }

    /**
     * @private
     */
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
     * 加载图片（会先卸载并尝试释放旧位图）。
     * @param url 图片地址。
     * @param back 成功回调，参数为本实例；可省略。
     * @param fail 失败回调，参数为本实例；可省略。
     * @param process 进度回调 <code>(loader, per)</code>；可省略。
     * @example
     * <listing version="3.0">
     * var img:ImageLoader = new ImageLoader();
     * img.loadImage('a.png', onOk);
     * </listing>
     * @see #reload()
     * @see #unloadAndDispose()
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
     * 卸载内容并 dispose 位图数据。
     * @example
     * <listing version="3.0">
     * img.unloadAndDispose();
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
     * 用当前 URL 重新加载。
     * @example
     * <listing version="3.0">
     * img.reload();
     * </listing>
     */
    public function reload():void {
        loadImage(_url);
    }

    /**
     * @private
     */
    private function removeListener():void {
        contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onIOError);
        contentLoaderInfo.removeEventListener(Event.COMPLETE, onComplete);
        contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, onProcess);
    }

    /**
     * @private
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
     * @private
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
     * @private
     */
    private function onProcess(e:ProgressEvent):void {
        if (_process != null) {
            var per:Number = e.bytesLoaded / e.bytesTotal;
            _process(this, per);
        }
    }
}
}
