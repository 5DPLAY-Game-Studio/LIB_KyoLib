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
import flash.display.Sprite;
import flash.geom.Point;

import mx.controls.Alert;

/**
 * 幻灯片单页加载器：按 URL 加载图片或 SWF，并缓存完成状态。
 *
 * <p>URL 可带后缀分隔写法 <code>path|ext</code>（如 <code>a.swf|.swf</code>）以选择 <code>SwfLoader</code> 或 <code>ImageLoader</code>。</p>
 *
 * @see ImageLoader
 * @see SwfLoader
 * @see #load()
 */
public class PicLoader extends Sprite {
    /**
     * @param size 目标显示尺寸。
     * @param url 资源地址，可选。
     */
    public function PicLoader(size:Point, url:String = null) {
        this._size = size;
        this.url   = url;
    }

    /**
     * 页序号或业务用 ID。
     * @default 0
     */
    public var id:int;
    /** @private */
    private var _size:Point;
    /** @private 资源 URL */
    private var url:String;
    /** @private 是否已成功加载过 */
    private var _isComplete:Boolean;
    /** @private */
    private var _succBack:Function;
    /** @private */
    private var _failBack:Function;
    /** @private */
    private var _processBack:Function;
    /** @private 内部 ImageLoader / SwfLoader */
    private var _loader:*;

    /**
     * 内部加载器实例（加入本 Sprite 显示列表）。
     * @return <code>ImageLoader</code> 或 <code>SwfLoader</code>。
     * @default null
     */
    public function get loader():* {
        return _loader;
    }

    /** @private */
    public function set loader(v:*):void {
        _loader = v;
        addChild(_loader);
    }

    /**
     * 从显示列表移除内部加载器（不 dispose）。
     * @example
     * <listing version="3.0">
     * pic.clear();
     * </listing>
     * @see #unload()
     */
    public function clear():void {
        try {
            removeChild(_loader);
        }
        catch (e:*) {
        }
    }

    /**
     * 移除并卸载内部加载器。
     * @see #destory()
     * @see #unloadLoader()
     */
    public final function unload():void {
        removeLoader();
    }

    /**
     * 按类型卸载给定加载器。
     * @param l <code>ImageLoader</code> 或 <code>SwfLoader</code>。
     */
    public final function unloadLoader(l:*):void {
        if (l is ImageLoader) {
            (l as ImageLoader).unloadAndDispose();
        }
        if (l is SwfLoader) {
            (l as SwfLoader).unload();
        }
    }

    /**
     * 销毁：等同于 <code>unload</code>。
     * @example
     * <listing version="3.0">
     * pic.destory();
     * </listing>
     */
    public final function destory():void {
        removeLoader();
    }

    /**
     * 开始加载；若已成功过则直接回调成功。
     * @param success 成功回调，参数为本实例，可选。
     * @param fail 失败回调，参数为本实例，可选。
     * @param process 进度回调 <code>(pic, per)</code>，可选。
     * @example
     * <listing version="3.0">
     * pic.load(onOk, onFail, onProgress);
     * </listing>
     */
    public final function load(success:Function = null, fail:Function = null, process:Function = null):void {
        if (_isComplete) {
            if (success != null) {
                success(this);
            }
            return;
        }

        _succBack    = success;
        _failBack    = fail;
        _processBack = process;

        if (url.indexOf('|') != -1) {
            var us:Array      = url.split('|');
            var url2:String   = us[0];
            var prefix:String = us[1].toLocaleLowerCase();
            if (prefix == '.swf') {
                loader = new SwfLoader(url2, _size, loadSuccess, loadFail, loadProcess);
            }
            else {
                loader = new ImageLoader(url2, _size, loadSuccess, loadFail, loadProcess);
            }
        }
        else {
            loader = new ImageLoader(url, _size, loadSuccess, loadFail);
        }
    }

    /**
     * @private 加载成功。
     */
    private function loadSuccess(...params):void {
        _isComplete = true;
        if (_succBack != null) {
            _succBack(this);
        }

        _succBack    = null;
        _failBack    = null;
        _processBack = null;
    }

    /**
     * @private 加载失败：弹 Alert 并回调。
     */
    private function loadFail(...params):void {
        Alert.show('加载幻灯片资源出错');
        if (_failBack != null) {
            _failBack(this);
        }

        _succBack    = null;
        _failBack    = null;
        _processBack = null;
    }

    /**
     * @private 进度转发。
     */
    private function loadProcess(l:*, per:Number):void {
        if (_processBack != null) {
            _processBack(this, per);
        }
    }

    /**
     * @private 移除并卸载内部加载器。
     */
    private function removeLoader():void {
        if (_loader) {
            try {
                removeChild(_loader);
            }
            catch (e:Error) {
            }
            unloadLoader(_loader);
            _loader = null;
        }
    }

}
}
