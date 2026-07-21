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
import flash.display.LoaderInfo;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IOErrorEvent;
import flash.events.ProgressEvent;
import flash.net.URLRequest;
import flash.system.ApplicationDomain;
import flash.utils.Dictionary;

/**
 * 全部 SWF 加载完成时派发。
 *
 * @eventType flash.events.Event.COMPLETE
 */
[Event(name='complete', type='flash.events.Event')]
/**
 * 单个文件加载进度转发。
 *
 * @eventType flash.events.ProgressEvent.PROGRESS
 */
[Event(name='progress', type='flash.events.ProgressEvent')]
/**
 * 单个文件 IO 错误转发。
 *
 * @eventType flash.events.IOErrorEvent.IO_ERROR
 */
[Event(name='ioError', type='flash.events.IOErrorEvent')]
/**
 * 批量加载 SWF，按 URL 缓存 <code>ApplicationDomain</code>，并按类名取定义。
 *
 * @see #load()
 * @see #getClass()
 * @see #addSwf()
 */
public class KyoClassLoader extends EventDispatcher {
    /**
     * 构造函数。
     */
    public function KyoClassLoader() {
    }

    /** @private id → ApplicationDomain */
    private var _classes:Object = {};
    /** @private */
    private var _urls:Array;
    /** @private 默认查询用的 SWF id（首次成功加载的 URL） */
    private var _defaultId:String;
    /** @private Loader → url */
    private var _directory:Dictionary = new Dictionary();
    /** @private */
    private var _loading:Boolean;

    /** @private */
    private var _loadedAmount:int;

    /**
     * 已开始加载的个数（含当前项）。
     */
    public function get loadedAmount():int {
        return _loadedAmount;
    }

    /**
     * 从已加载 SWF 的域中取类定义。
     * @param className 完整类名。
     * @param swf SWF 的 URL（作 id）；省略则用首次加载成功的 URL。
     * @return 类定义。
     * @throws Error 指定 SWF 未加载，或域中无该类。
     * @example
     * <listing version="3.0">
     * var C:Class = cl.getClass('pkg.MyMc');
     * </listing>
     */
    public function getClass(className:String, swf:String = null):Class {
        swf ||= _defaultId;
        var app:ApplicationDomain = _classes[swf];
        if (!app) {
            throw new Error(swf + '未加载!');
            return null;
        }
        try {
            return app.getDefinition(className) as Class;
        }
        catch (e:Error) {
            throw new Error('在 ' + swf + ' 中找不到 ' + className + ' 的定义!');
            trace('KyoClassLoader ::', e);
        }
        return null;
    }

    /**
     * 加载一个或多个 SWF（未完成前不可再次调用）。
     * @param url 单个 URL 字符串，或 URL 数组。
     * @throws Error 上一次加载尚未结束。
     * @example
     * <listing version="3.0">
     * cl.load(['a.swf', 'b.swf']);
     * </listing>
     */
    public function load(url:Object):void {
        if (_loading) {
            throw new Error('不可以在没完成加载时继续调用此方法!');
        }

        if (url is String) {
            _urls = [url];
        }
        if (url is Array) {
            _urls = url as Array;
        }
        _loadedAmount = 0;
        loadNext();

        _loading = true;
    }

    /**
     * 手动登记已有 Loader 的域，并以 id 索引，随后卸载该 Loader。
     * @param id 索引键（通常为 URL）。
     * @param swf 已加载完成的 Loader。
     * @example
     * <listing version="3.0">
     * cl.addSwf('ui.swf', loader);
     * </listing>
     */
    public function addSwf(id:String, swf:Loader):void {
        _classes[id] = swf.contentLoaderInfo.applicationDomain;
        try {
            swf.unloadAndStop(true);
        }
        catch (e:Error) {
            swf.unload();
        }
    }

    /**
     * @private
     */
    private function loadNext():Boolean {
        if (_urls.length < 1) {
            return false;
        }
        _loadedAmount++;
        var loader:Loader = new Loader();
        loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadComplete);
        loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, loadProgress);
        loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, loadError);

        var url:String = _urls.shift();
        loader.load(new URLRequest(url));
        _directory[loader] = url;

        return true;
    }

    /**
     * @private
     */
    private function removeLoader(loader:Loader):void {
        loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, loadComplete);
        loader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, loadProgress);
        loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, loadError);
        try {
            loader.unloadAndStop(true);
        }
        catch (e:Error) {
            loader.unload();
        }
        loader = null;
    }

    /**
     * @private
     */
    private function checkComplete():void {
        if (loadNext() == false) {
            _loading = false;
            dispatchEvent(new Event(Event.COMPLETE));
        }
    }

    /**
     * @private
     */
    private function loadComplete(e:Event):void {
        var loaderinfo:LoaderInfo = e.currentTarget as LoaderInfo;
        var loader:Loader         = loaderinfo.loader;
        var id:String             = _directory[loader];
        _defaultId ||= id;
        _classes[id]              = loaderinfo.applicationDomain;
        removeLoader(loader);

        checkComplete();
    }

    /**
     * @private
     */
    private function loadProgress(e:ProgressEvent):void {
        dispatchEvent(e);
    }

    /**
     * @private
     */
    private function loadError(e:IOErrorEvent):void {
        var loader:Loader = (e.currentTarget as LoaderInfo).loader;
        var id:String;
        if (loader && loader.loaderInfo) {
            id = loader.loaderInfo.loaderURL;
        }

        trace('loadError', id);
        dispatchEvent(e);

        checkComplete();
    }

}
}
