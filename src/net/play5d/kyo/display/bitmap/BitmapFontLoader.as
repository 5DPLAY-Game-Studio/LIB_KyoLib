/*
 * Copyright (C) 2021-2026, 5DPLAY Game Studio
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

package net.play5d.kyo.display.bitmap {
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.events.Event;

import net.play5d.kyo.loader.BitmapLoader;
import net.play5d.kyo.loader.KyoURLLoader;

/**
 * 位图字体加载与缓存。
 *
 * <p>按 Starling 字体 XML 解析贴图路径，加载后以 <code>info.&#64;face</code> 为键存入字典，可通过 <code>getFont</code> 取出。</p>
 *
 * @see BitmapFont
 * @see #loadFonts()
 * @see #loadFont()
 * @see #getFont()
 */
public class BitmapFontLoader {
    /**
     * 构造空的字体加载器。
     */
    public function BitmapFontLoader() {
    }

    /** @private 待加载的 XML URL 队列 */
    [ArrayElementType('String')]
    private var _urls:Array;
    /** @private face → BitmapFont */
    private var _fontObj:Object = {};
    /** @private 本次批量加载的总数 */
    private var _loadAmount:int;
    /** @private 全部完成回调 */
    private var _loadBack:Function;
    /** @private 进度回调，参数为 0–1 */
    private var _loadProgress:Function;

    /**
     * 清空已缓存的字体。
     * @example
     * <listing version="3.0">
     * loader.clear();
     * </listing>
     */
    public function clear():void {
        _fontObj = {};
    }

    /**
     * 按 URL 列表依次加载多套字体 XML（及对应贴图）。
     * @param urls 字体 XML 的 URL 数组。
     * @param back 全部完成时的无参回调，可选。
     * @param progress 进度回调，参数为已完成比例（0–1），可选。
     * @example
     * <listing version="3.0">
     * loader.loadFonts(['font/ui.xml'], onDone, onProgress);
     * </listing>
     * @see #loadFont()
     * @see #getFont()
     */
    [ArrayElementType('String')]
    public function loadFonts(urls:Array, back:Function = null, progress:Function = null):void {
        _loadBack     = back;
        _loadProgress = progress;

        _urls       = urls;
        _loadAmount = urls.length;

        loadNext();
    }

    /**
     * 加载单套字体：根据 XML 中的 page 文件名，在 <code>url</code> 同目录下取贴图。
     * @param url 字体 XML 的 URL（用于解析贴图相对路径）。
     * @param fontXML 已解析的字体 XML。
     * @param back 成功回调，可选。
     * @param fail 失败回调，可选。
     * @example
     * <listing version="3.0">
     * loader.loadFont('assets/font/ui.xml', xml, onOk, onFail);
     * </listing>
     * @see #loadFonts()
     * @see #addFont()
     */
    public function loadFont(url:String, fontXML:XML, back:Function = null, fail:Function = null):void {
        loadBitmapData(resolveSiblingPath(url, fontXML.pages.page.@file), fontXML, back, fail);
    }

    /**
     * 用已有 XML 与贴图直接注册字体（不发起网络加载）。
     * @param xml 字体 XML。
     * @param bitmap 字体贴图。
     * @example
     * <listing version="3.0">
     * loader.addFont(xml, bd);
     * </listing>
     * @see #getFont()
     */
    public function addFont(xml:XML, bitmap:BitmapData):void {
        var fontId:String = xml.info.@face;
        _fontObj[fontId]  = new BitmapFont(xml, bitmap);
    }

    /**
     * 按字体名（XML <code>info.&#64;face</code>）取已缓存的 <code>BitmapFont</code>。
     * @param id 字体 face 名。
     * @return 对应字体；未加载过则为 <code>null</code>。
     * @example
     * <listing version="3.0">
     * var font:BitmapFont = loader.getFont('UI');
     * </listing>
     */
    public function getFont(id:String):BitmapFont {
        return _fontObj[id];
    }

    /** @private 批量加载全部完成。 */
    private function loadComplete():void {
        if (_loadBack != null) {
            _loadBack();
            _loadBack = null;
        }
        _loadProgress = null;
    }

    /** @private 队列中取下一个 XML 加载。 */
    private function loadNext():void {
        if (_loadProgress != null) {
            _loadProgress((_loadAmount - _urls.length) / _loadAmount);
        }

        if (_urls.length < 1) {
            loadComplete();

            return;
        }

        var url:String = _urls.shift();
        KyoURLLoader.load(url, onLoadXMLFinish, loadXMLFail);

        function onLoadXMLFinish(v:String):void {
            var xml:XML = new XML(v);
            loadBitmapData(resolveSiblingPath(url, xml.pages.page.@file), xml, loadNext, loadNext);
        }

        function loadXMLFail():void {
            trace('BitmapFontLoader.loadXMLFail::' + url);
            loadNext();
        }
    }

    /** @private 加载贴图并注册 <code>BitmapFont</code>。 */
    private function loadBitmapData(bpUrl:String, xml:XML, back:Function = null, fail:Function = null):void {
        var fontId:String = xml.info.@face;

        new BitmapLoader().load(bpUrl, loadBpComplete, loadBpFail);

        function loadBpComplete(b:Bitmap):void {
            _fontObj[fontId] = new BitmapFont(xml, b.bitmapData);
            if (back != null) {
                back();
            }
        }

        function loadBpFail(e:Event):void {
            trace('BitmapFontLoader.loadBpFail::' + bpUrl);
            if (fail != null) {
                fail();
            }
        }
    }

    /**
     * @private 取 <code>baseUrl</code> 所在目录下的兄弟路径。
     */
    private function resolveSiblingPath(baseUrl:String, fileName:String):String {
        return baseUrl.substr(0, baseUrl.lastIndexOf('/') + 1) + fileName;
    }

}
}
