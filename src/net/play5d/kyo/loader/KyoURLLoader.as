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
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.ProgressEvent;
import flash.events.SecurityErrorEvent;
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.net.URLRequestMethod;
import flash.net.URLVariables;
import flash.utils.ByteArray;

/**
 * URL 文本 / 二进制加载与 POST，以及字节 BOM 编码探测。
 *
 * <p><b>首选</b>文本与字节 HTTP 入口；显示对象加载见 <code>KyoLoaderLite</code>。勿用 <code>AJAX</code> 写新代码。</p>
 *
 * @see #load()
 * @see #post()
 * @see #getFileType()
 * @see KyoLoaderLite
 */
public class KyoURLLoader {
    /** Unicode（UTF-16 LE）BOM 探测结果。 */
    public static const TYPE_UNICODE:String            = 'Unicode';
    /** Unicode big endian（UTF-16 BE）BOM 探测结果。 */
    public static const TYPE_UNICODE_BIG_ENDIAN:String = 'Unicode big endian';
    /** UTF-8 BOM 探测结果。 */
    public static const TYPE_UTF8:String               = 'UTF-8';
    /** 无已知 BOM 时视为 ANSI。 */
    public static const TYPE_ANSI:String               = 'ANSI';
    /**
     * 为 <code>true</code> 时 IO 错误会 <code>trace</code>。
     * @default true
     */
    public static var showDebug:Boolean                = true;
    /**
     * 最近一次 <code>load</code> 失败时的错误字符串；成功前会清空。
     */
    public static var errorStr:String;

    /**
     * 加载 URL 数据。
     * @param url 地址。
     * @param back 成功回调，参数为 <code>loader.data</code>。
     * @param failBack 失败回调，无参数；可省略。
     * @param param 可选，键值写入 <code>URLLoader</code> 属性（如 <code>dataFormat</code>）。
     * @param progress 进度回调，参数为 0~1 比例；可省略。
     * @example
     * <listing version="3.0">
     * KyoURLLoader.load('a.txt', onData);
     * </listing>
     */
    public static function load(
        url     :String,
        back    :Function,
        failBack:Function = null,
        param   :Object = null,
        progress:Function = null
    ):void {
        errorStr = null;

        var loader:URLLoader = new URLLoader();
        if (param) {
            for (var i:String in param) {
                loader[i] = param[i];
            }
        }
        loader.addEventListener(Event.COMPLETE, onComplete);
        loader.addEventListener(IOErrorEvent.IO_ERROR, onError);
        loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onError2);
        if (progress != null) {
            loader.addEventListener(ProgressEvent.PROGRESS, onProgress);
        }
        loader.load(new URLRequest(url));

        function onComplete(e:Event):void {
            if (back != null) {
                back(loader.data);
            }
            clear();
        }

        function onError(e:IOErrorEvent):void {
            errorStr = e.toString();
            if (failBack != null) {
                failBack();
            }
            clear();
            if (showDebug) {
                trace(e);
            }
        }

        function onError2(e:SecurityErrorEvent):void {
            errorStr = e.toString();
            if (failBack != null) {
                failBack();
            }
            clear();
        }

        function onProgress(e:ProgressEvent):void {
            if (progress != null) {
                progress(e.bytesLoaded / e.bytesTotal);
            }
        }

        function clear():void {
            if (loader == null) {
                return;
            }
            loader.removeEventListener(Event.COMPLETE, onComplete);
            loader.removeEventListener(IOErrorEvent.IO_ERROR, onError);
            loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onError2);
            if (progress != null) {
                loader.removeEventListener(ProgressEvent.PROGRESS, onProgress);
            }
            loader = null;
        }
    }

    /**
     * 发送 POST 请求。
     * @param url 地址。
     * @param data <code>URLVariables</code> 或普通 Object（会转为 URLVariables）。
     * @param back 成功回调，参数为响应数据；可省略。
     * @param failBack 失败回调，无参数；可省略。
     * @example
     * <listing version="3.0">
     * KyoURLLoader.post('api.php', {id: 1}, onData);
     * </listing>
     */
    public static function post(url:String, data:Object, back:Function = null, failBack:Function = null):void {
        var loader:URLLoader = new URLLoader();
        loader.addEventListener(Event.COMPLETE, onComplete);
        loader.addEventListener(IOErrorEvent.IO_ERROR, onError);

        var uq:URLRequest = new URLRequest(url);
        uq.method         = URLRequestMethod.POST;
        if (data is URLVariables) {
            uq.data = data;
        }
        else {
            var uv:URLVariables = new URLVariables();
            for (var i:String in data) {
                uv[i] = data[i];
            }
            uq.data = uv;
        }
        loader.load(uq);

        function onComplete(e:Event):void {
            if (back != null) {
                back(loader.data);
            }
            loader = null;
        }

        function onError(e:IOErrorEvent):void {
            if (failBack != null) {
                failBack();
            }
            loader = null;
            if (showDebug) {
                trace(e);
            }
        }
    }

    /**
     * 根据文件头 BOM 判断文本编码类型（读取后复位 position）。
     * @param fileData 文件字节。
     * @return <code>TYPE_UNICODE</code> 等常量之一。
     * @example
     * <listing version="3.0">
     * var t:String = KyoURLLoader.getFileType(ba);
     * </listing>
     */
    public static function getFileType(fileData:ByteArray):String {
        var b0:int = fileData.readUnsignedByte();
        var b1:int = fileData.readUnsignedByte();

        fileData.position = 0;

        if (b0 == 0xFF && b1 == 0xFE) {
            return TYPE_UNICODE;
        }
        if (b0 == 0xFE && b1 == 0xFF) {
            return TYPE_UNICODE_BIG_ENDIAN;
        }
        if (b0 == 0xEF && b1 == 0xBB) {
            return TYPE_UTF8;
        }

        return TYPE_ANSI;
    }

}
}
