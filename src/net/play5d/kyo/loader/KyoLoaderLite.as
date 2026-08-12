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
import flash.display.DisplayObject;
import flash.display.Loader;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.ProgressEvent;
import flash.events.SecurityErrorEvent;
import flash.net.URLLoaderDataFormat;
import flash.net.URLRequest;
import flash.system.LoaderContext;
import flash.utils.ByteArray;

/**
 * 静态轻量加载工具：显示对象、Loader、二进制与字节转显示对象。
 *
 * <p><b>首选</b>显示对象加载入口；文本/字节 HTTP 见 <code>KyoURLLoader</code>。二者勿合并。</p>
 *
 * @see #load()
 * @see #loadLoader()
 * @see #loadBytes()
 * @see #bytesToDisplay()
 * @see KyoURLLoader
 */
public class KyoLoaderLite {
    /**
     * 加载 URL，成功回调显示内容。
     * @param url 资源地址。
     * @param back 成功回调，参数为 <code>DisplayObject</code>。
     * @param fail 失败回调，无参数。
     * @param progress 进度回调，参数为 0~1 比例。
     * @example
     * <listing version="3.0">
     * KyoLoaderLite.load('a.swf', onOk, onFail, onProg);
     * </listing>
     */
    public static function load(url:String, back:Function, fail:Function, progress:Function):void {
        var l:Loader = new Loader();
        l.contentLoaderInfo.addEventListener(Event.COMPLETE, loadComplete);
        l.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, ioError);
        l.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, progressHandler);
        l.load(new URLRequest(url));

        function loadComplete(e:Event):void {
            var d:DisplayObject = l.content;
            // 先作废进度回调，避免 COMPLETE 之后滞后 PROGRESS 污染上层步进
            progress = null;
            if (back != null) {
                back(d);
            }
            clear();
        }

        function ioError(e:IOErrorEvent):void {
            progress = null;
            if (fail != null) {
                fail();
            }
            clear();
        }

        function progressHandler(e:ProgressEvent):void {
            if (progress != null && e.bytesTotal > 0) {
                progress(e.bytesLoaded / e.bytesTotal);
            }
        }

        function clear():void {
            if (l == null) {
                return;
            }

            l.contentLoaderInfo.removeEventListener(Event.COMPLETE, loadComplete);
            l.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, ioError);
            l.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, progressHandler);
            l.unloadAndStop(true);
            l = null;
        }
    }

    /**
     * 加载 URL，成功回调 <code>Loader</code> 实例（不清空 Loader）。
     * @param url 资源地址。
     * @param back 成功回调，参数为 <code>Loader</code>。
     * @param fail 失败回调，无参数。
     * @param progress 进度回调，参数为 0~1 比例。
     * @example
     * <listing version="3.0">
     * KyoLoaderLite.loadLoader('a.swf', onOk, onFail, onProg);
     * </listing>
     */
    public static function loadLoader(url:String, back:Function, fail:Function, progress:Function):void {
        var l:Loader = new Loader();
        l.contentLoaderInfo.addEventListener(Event.COMPLETE, loadComplete);
        l.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, ioError);
        l.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, progressHandler);
        l.load(new URLRequest(url));

        function loadComplete(e:Event):void {
            progress = null;
            if (back != null) {
                back(l);
            }
            clear();
        }

        function ioError(e:IOErrorEvent):void {
            progress = null;
            if (fail != null) {
                fail();
            }
            clear();
        }

        function progressHandler(e:ProgressEvent):void {
            if (progress != null && e.bytesTotal > 0) {
                progress(e.bytesLoaded / e.bytesTotal);
            }
        }

        function clear():void {
            if (l == null) {
                return;
            }

            l.contentLoaderInfo.removeEventListener(Event.COMPLETE, loadComplete);
            l.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, ioError);
            l.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, progressHandler);
        }
    }

    /**
     * 以二进制方式加载 URL（委托 <code>KyoURLLoader</code>）。
     * @param url 资源地址。
     * @param back 成功回调，参数为 <code>ByteArray</code>。
     * @param fail 失败回调；可省略。
     * @param progress 进度回调，参数为 0~1 比例；可省略。
     * @example
     * <listing version="3.0">
     * KyoLoaderLite.loadBytes('a.bin', onBytes);
     * </listing>
     * @see net.play5d.kyo.loader.KyoURLLoader#load()
     */
    public static function loadBytes(url:String, back:Function, fail:Function = null, progress:Function = null):void {
        KyoURLLoader.load(url, onData, fail, {dataFormat: URLLoaderDataFormat.BINARY}, progress);

        function onData(data:*):void {
            if (back != null) {
                back(data as ByteArray);
            }
        }
    }

    /**
     * 将字节数组加载为显示对象（允许代码导入）。
     * @param bytes 二进制数据。
     * @param onComplete 成功回调，参数为 <code>Loader</code>；可省略。
     * @param onError 失败回调；可省略。
     * @return 用于加载的 <code>Loader</code>。
     * @example
     * <listing version="3.0">
     * var l:Loader = KyoLoaderLite.bytesToDisplay(ba, onOk);
     * </listing>
     */
    public static function bytesToDisplay(bytes:ByteArray, onComplete:Function = null, onError:Function = null):Loader {
        var loader:Loader = new Loader();
        loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoadComplete);
        loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onLoadError);
        loader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onLoadError);

        var ctx:LoaderContext = new LoaderContext();
        ctx.allowCodeImport   = true;
        loader.loadBytes(bytes, ctx);

        function onLoadComplete(e:Event):void {
            if (onComplete != null) {
                onComplete(loader);
            }
        }

        function onLoadError(e:*):void {
            if (onError != null) {
                onError();
            }
            trace(e);
        }

        return loader;
    }
}
}
