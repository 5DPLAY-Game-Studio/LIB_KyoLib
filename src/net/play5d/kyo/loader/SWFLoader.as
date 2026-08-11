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
import flash.display.Loader;
import flash.events.Event;
import flash.net.URLLoaderDataFormat;
import flash.net.URLRequest;
import flash.utils.ByteArray;

/**
 * 先解析 SWF 头再加载 SWF 内容的 <code>Loader</code>。
 *
 * @see SwfHeaderInfo
 * @see #loadSwf()
 * @see #headInfo
 */
public class SWFLoader extends Loader {
    /**
     * 构造并开始加载 SWF。
     * @param url SWF 地址。
     * @param back 内容加载完成回调；可省略。
     * @example
     * <listing version="3.0">
     * var l:SWFLoader = new SWFLoader('a.swf', onReady);
     * </listing>
     */
    public function SWFLoader(url:String, back:Function = null) {
        loadSwf(url, back);
    }

    /**
     * 解析得到的 SWF 头信息。
     * @default null
     */
    public var headInfo:SwfHeaderInfo;

    /**
     * 先加载二进制解析头，再加载 SWF。
     * @param url SWF 地址。
     * @param back 内容加载完成回调。
     * @param fail 头或数据失败回调；可省略。
     * @example
     * <listing version="3.0">
     * var l:SWFLoader = new SWFLoader('a.swf', onReady);
     * </listing>
     */
    public function loadSwf(url:String, back:Function, fail:Function = null):void {
        loadHead(url, function ():void {
            loadFlash(url, back);
        }, fail);
    }

    /**
     * @private
     */
    private function loadHead(url:String, back:Function, fail:Function):void {
        KyoURLoader.load(url, ulcom, fail, {dataFormat: URLLoaderDataFormat.BINARY});

        function ulcom(b:ByteArray):void {
            if (!b) {
                if (fail != null) {
                    fail();
                }

                return;
            }
            headInfo = new SwfHeaderInfo(b);
            if (back != null) {
                back();
            }
        }
    }

    /**
     * @private
     */
    private function loadFlash(url:String, back:Function):void {
        contentLoaderInfo.addEventListener(Event.COMPLETE, loadCom);
        load(new URLRequest(url));

        function loadCom(e:Event):void {
            contentLoaderInfo.removeEventListener(Event.COMPLETE, loadCom);
            if (back != null) {
                back();
            }
        }
    }

}
}
