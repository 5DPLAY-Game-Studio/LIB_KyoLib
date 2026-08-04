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
import flash.media.Sound;
import flash.net.URLLoader;
import flash.net.URLRequest;

/**
 * 批量加载音频，按 URL 缓存，并可从列表 XML 批量拉取。
 *
 * @see #loadSounds()
 * @see #getSound()
 * @see #loadPath()
 */
public class KyoSoundLoader {
    /** @private */
    private var _urls:Array;
    /** @private */
    private var _curUrl:String;
    /** @private url → Sound */
    private var _soundObj:Object = {};
    /** @private */
    private var _loadBack:Function;
    /** @private */
    private var _loadProcess:Function;
    /** @private */
    private var _loadLength:int;

    /**
     * 关闭已缓存声音并清空表。
     * @example
     * <listing version="3.0">
     * loader.unload();
     * </listing>
     */
    public function unload():void {
        if (_soundObj) {
            for each (var s:Sound in _soundObj) {
                s.close();
            }
            _soundObj = {};
        }
    }

    /**
     * 按 URL 列表顺序加载声音。
     * @param urls 声音 URL 数组。
     * @param back 全部结束回调（含失败后继续）；无参数；可省略。
     * @param process 总进度回调，参数为 0~1；可省略。
     * @example
     * <listing version="3.0">
     * loader.loadSounds(['a.mp3', 'b.mp3'], onAll);
     * </listing>
     */
    public function loadSounds(urls:Array, back:Function = null, process:Function = null):void {
        _loadBack    = back;
        _loadProcess = process;
        _urls        = urls.concat();
        _loadLength  = urls.length;

        loadNext();
    }

    /**
     * 获取已加载的 <code>Sound</code>。
     * @param pathOrName 完整路径（含后缀），或文件名（不含后缀）。
     * @return 声音实例；未找到则 <code>null</code>。
     * @example
     * <listing version="3.0">
     * var s:Sound = loader.getSound('bgm');
     * </listing>
     */
    public function getSound(pathOrName:String):Sound {
        if (_soundObj[pathOrName]) {
            return _soundObj[pathOrName];
        }

        for (var i:String in _soundObj) {
            var name:String = i.substr(i.lastIndexOf('/') + 1);
            name            = name.substr(0, name.lastIndexOf('.'));
            if (name == pathOrName) {
                return _soundObj[i];
            }
        }

        return null;
    }

    /**
     * 手动登记声音到缓存表。
     * @param url 索引键（通常为路径）。
     * @param sound 声音实例。
     * @example
     * <listing version="3.0">
     * loader.addSound('a.mp3', sound);
     * </listing>
     */
    public function addSound(url:String, sound:Sound):void {
        _soundObj[url] = sound;
    }

    /**
     * 读取目录下列表 XML，再批量加载其中的声音路径。
     * @param path 目录前缀。
     * @param listXML 列表文件名（相对 path）。
     * @param back 全部加载结束回调；可省略。
     * @example
     * <listing version="3.0">
     * loader.loadPath('snd', 'list.xml', onAll);
     * </listing>
     */
    public function loadPath(path:String, listXML:String, back:Function = null):void {
        var l:URLLoader = new URLLoader(new URLRequest(path + '/' + listXML));
        l.addEventListener(Event.COMPLETE, function (e:Event):void {
            var xml:XML    = new XML(l.data);
            var urls:Array = [];
            for each (var i:Object in xml.children()) {
                urls.push(path + '/' + i.toString());
            }
            loadSounds(urls, back);
        });
    }

    /**
     * @private
     */
    private function loadNext():void {
        var url:String = _urls.shift();
        _curUrl        = url;

        var sound:Sound = new Sound(new URLRequest(url));
        sound.addEventListener(Event.COMPLETE, onLoadComplete);
        sound.addEventListener(ProgressEvent.PROGRESS, onLoadProgress);
        sound.addEventListener(IOErrorEvent.IO_ERROR, onLoadError);
    }

    /**
     * @private
     */
    private function loadFin():void {
        if (_loadBack != null) {
            _loadBack();
            _loadBack = null;
        }
    }

    /**
     * @private
     */
    private function onLoadProgress(e:ProgressEvent):void {
        if (_loadProcess != null) {
            var v:Number   = e.bytesLoaded / e.bytesTotal;
            var cur:Number = _loadLength - _urls.length - 1 + v;
            _loadProcess(cur / _loadLength);
        }
    }

    /**
     * @private
     */
    private function onLoadComplete(e:Event):void {
        var snd:Sound = e.currentTarget as Sound;
        snd.removeEventListener(Event.COMPLETE, onLoadComplete);
        snd.removeEventListener(IOErrorEvent.IO_ERROR, onLoadError);
        snd.removeEventListener(ProgressEvent.PROGRESS, onLoadProgress);

        _soundObj[_curUrl] = snd;

        if (_urls.length < 1) {
            loadFin();
        }
        else {
            loadNext();
        }
    }

    /**
     * @private
     */
    private function onLoadError(e:IOErrorEvent):void {
        var snd:Sound = e.currentTarget as Sound;
        snd.removeEventListener(Event.COMPLETE, onLoadComplete);
        snd.removeEventListener(IOErrorEvent.IO_ERROR, onLoadError);
        snd.removeEventListener(ProgressEvent.PROGRESS, onLoadProgress);

        trace('KyoSoundLoader.onLoadError :: 加载声音失败 : ' + snd.url);

        if (_urls.length < 1) {
            loadFin();
        }
        else {
            loadNext();
        }
    }
}
}
