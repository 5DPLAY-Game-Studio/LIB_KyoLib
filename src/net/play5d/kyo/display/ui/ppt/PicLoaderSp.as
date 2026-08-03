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
import flash.events.Event;
import flash.geom.Point;

import net.play5d.kyo.SuperPlayer;
import net.play5d.kyo.utils.KyoStringUtils;
/**
 * 基于 <code>SuperPlayer</code> 的幻灯片页加载器，支持图片占位与视频播放完成回调。
 *
 * <p>非当前页且判定为位图时，仅画黑底占位而不真正加载，以节省资源。</p>
 *
 * @see SuperPlayer
 * @see #load()
 * @see #finish()
 */
public class PicLoaderSp extends Sprite {
    /**
     * @param size 显示区域尺寸。
     */
    public function PicLoaderSp(size:Point) {
        this._size = size;
    }

    /**
     * 视频播放完成时的无参回调。
     * @default null
     */
    public var onFinish:Function;
    /**
     * <code>initlize</code> 后是否判定为位图扩展名（jpg/jpeg/gif/png）。
     * @default false
     */
    public var isBitmap:Boolean;
    /** @private */
    private var _player:SuperPlayer;
    /** @private */
    private var _size:Point;
    /** @private */
    private var _url:String;

    /**
     * 设置资源 URL，并根据扩展名更新 <code>isBitmap</code>。
     * @param v 资源地址。
     * @example
     * <listing version="3.0">
     * loader.initlize('clip.mp4');
     * </listing>
     */
    public function initlize(v:String):void {
        _url           = v;
        var pfx:String = KyoStringUtils.getExtension(v);
        var pa:Array   = ['jpg', 'jpeg', 'gif', 'png'];
        isBitmap       = pa.indexOf(pfx) != -1;
    }

    /**
     * 卸载当前播放器。
     * @see #destroy()
     */
    public final function unload():void {
        removeLoader();
    }

    /**
     * 销毁：等同于 <code>unload</code>。
     * @example
     * <listing version="3.0">
     * loader.destroy();
     * </listing>
     */
    public final function destroy():void {
        removeLoader();
    }

    /**
     * 加载 / 播放资源。
     *
     * <p><code>isCurrent</code> 为 <code>false</code> 且为位图时只画占位并立即回调。</p>
     *
     * @param back 加载完成或占位完成的无参回调，可选。
     * @param isCurrent 是否作为当前页（需要真实加载）。
     * @example
     * <listing version="3.0">
     * loader.load(onReady, true);
     * </listing>
     */
    public final function load(back:Function = null, isCurrent:Boolean = false):void {
        if (!_url) {
            trace('PicLoader : url is null!');
            return;
        }
        removeLoader();
        loadurl(_url, back, isCurrent);
    }

    /**
     * 是否已播放结束（视频时看 <code>videoPlaying</code>；其它类型恒为 <code>true</code>）。
     * @return 是否可视为播放结束。
     * @example
     * <listing version="3.0">
     * if (loader.finish()) {
     *     goNext();
     * }
     * </listing>
     */
    public function finish():Boolean {
        if (_player && _player.type == SuperPlayer.TYPE_VIDEO) {
            return _player.videoPlaying == false;
        }
        return true;
    }

    /**
     * @private 按是否当前页 / 是否位图决定占位或 SuperPlayer 播放。
     */
    private function loadurl(url:String, back:Function, isCurrent:Boolean):void {
        if (!isCurrent) {
            if (isBitmap) {
                graphics.beginFill(0, 1);
                graphics.drawRect(0, 0, _size.x, _size.y);
                graphics.endFill();

                if (back != null) {
                    back();
                }
                return;
            }
        }

        _player = new SuperPlayer(_size.x, _size.y);
        _player.addEventListener(SuperPlayer.EVENT_LOAD_COMPLETE, loadBack);
        _player.addEventListener(SuperPlayer.EVENT_LOAD_FAIL, loadBack);
        _player.addEventListener(SuperPlayer.EVENT_PLAY_COMPLETE, playBack);
        _player.play(url);
        addChild(_player);

        function loadBack(e:Event):void {
            _player.removeEventListener(SuperPlayer.EVENT_LOAD_COMPLETE, loadBack);
            _player.removeEventListener(SuperPlayer.EVENT_LOAD_FAIL, loadBack);

            if (back != null) {
                back();
            }
        }
    }

    /**
     * @private 移除并销毁 SuperPlayer。
     */
    private function removeLoader():void {
        if (!_player) {
            return;
        }

        graphics.clear();

        try {
            removeChild(_player);
        }
        catch (e:Error) {
        }

        _player.removeEventListener(SuperPlayer.EVENT_PLAY_COMPLETE, playBack);

        _player.destroy();
        _player = null;
    }

    /**
     * @private 视频播完回调 <code>onFinish</code>。
     */
    private function playBack(e:Event):void {
        if (onFinish != null) {
            onFinish();
        }
    }

}
}
