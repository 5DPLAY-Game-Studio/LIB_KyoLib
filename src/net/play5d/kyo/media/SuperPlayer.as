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

package net.play5d.kyo.media {
import flash.display.DisplayObject;
import flash.display.Loader;
import flash.display.LoaderInfo;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.net.URLRequest;

import net.play5d.kyo.utils.KyoColor;

/**
 * 加载完成时派发。
 * @eventType SuperPlayer.EVENT_LOAD_COMPLETE
 */
[Event(name='load_complete', type='flash.events.Event')]
/**
 * 视频播放完成时派发。
 * @eventType SuperPlayer.EVENT_PLAY_COMPLETE
 */
[Event(name='play_complete', type='flash.events.Event')]
/**
 * 加载失败时派发。
 * @eventType SuperPlayer.EVENT_LOAD_FAIL
 */
[Event(name='load_fail', type='flash.events.Event')]
/**
 * 按扩展名播放视频 / SWF / 图片的容器播放器。
 *
 * @see #play()
 * @see #TYPE_VIDEO
 * @author kyo
 * @version 1.3
 */
public class SuperPlayer extends Sprite {
    /**
     * 加载完成事件类型。
     * @eventType load_complete
     */
    public static const EVENT_LOAD_COMPLETE:String = 'load_complete';
    /**
     * 播放完成事件类型。
     * @eventType play_complete
     */
    public static const EVENT_PLAY_COMPLETE:String = 'play_complete';
    /**
     * 加载失败事件类型。
     * @eventType load_fail
     */
    public static const EVENT_LOAD_FAIL:String     = 'load_fail';

    /** 当前为 Flash/SWF。 */
    public static const TYPE_FLASH:String  = 'type_is_flash';
    /** 当前为视频。 */
    public static const TYPE_VIDEO:String  = 'type_is_video';
    /** 当前为位图。 */
    public static const TYPE_BITMAP:String = 'type_is_bitmap';

    /**
     * @param width 显示宽。
     * @param height 显示高。
     */
    public function SuperPlayer(width:Number, height:Number) {
        _size = new Point(width, height);
        super();
    }

    /**
     * 当前媒体类型，见 <code>TYPE_FLASH</code> 等常量。
     */
    public var type:String;
    /**
     * 视频是否在加载后立即播放。
     * @default true
     */
    public var autoPlay:Boolean  = true;
    /**
     * 图片是否锁定宽高比。
     * @default false
     */
    public var lockRatio:Boolean = false;
    /**
     * 视为视频的扩展名列表。
     */
    public var video_pfxs:Array  = ['flv', 'mp4'];
    /**
     * 视为 SWF 的扩展名列表。
     */
    public var flash_pfxs:Array  = ['swf'];
    /**
     * 视为图片的扩展名列表。
     */
    public var pic_pfxs:Array    = ['jpg', 'jpeg', 'gif', 'png', 'bmp'];
    /** @private */
    private var _url:String;
    /** @private */
    private var _size:Point;
    /** @private */
    private var _img:Loader;
    /** @private */
    private var _swf:Loader;
    /** @private */
    private var _video:InsVideo;
    /** @private */
    private var _loopPlay:Boolean;

    /** @private */
    private var _bgColor:uint;

    /**
     * 背景填充色；设为 1 时不绘制背景。
     * @return 填充色。
     */
    public function get bgColor():uint {
        return _bgColor;
    }

    /**
     * @private
     */
    public function set bgColor(value:uint):void {
        _bgColor = value;

        graphics.clear();
        if (value == 1) {
            return;
        }

        graphics.beginFill(value, 1);
        graphics.drawRect(0, 0, _size.x, _size.y);
        graphics.endFill();
    }

    /**
     * 当前播放 URL。
     * @return URL。
     */
    public function get playingUrl():String {
        return _url;
    }

    /**
     * 图片或 SWF 的加载内容；视频时为 <code>null</code>。
     * @return 内容或 <code>null</code>。
     */
    public function get content():DisplayObject {
        if (_img) {
            return _img.loaderInfo.content;
        }
        if (_swf) {
            return _swf.loaderInfo.content;
        }
        return null;
    }

    /**
     * 视频是否正在播放。
     * @return 是否播放中。
     */
    public function get videoPlaying():Boolean {
        return _video && _video.playing;
    }

    /**
     * 视频元数据（时长等）。
     * @return 元数据对象。
     */
    public function get videoMetaData():Object {
        return _video.metadata;
    }

    /**
     * 按扩展名选择视频 / SWF / 图片并加载。
     * @param url 资源地址。
     * @param loop 视频播完是否循环。
     * @example
     * <listing version="3.0">
     * player.play('a.mp4', true);
     * </listing>
     */
    public function play(url:String, loop:Boolean = false):void {
        stop();

        _url      = url;
        _loopPlay = loop;

        var dxName:String = url.substr(url.lastIndexOf('.') + 1).toLocaleLowerCase();

        if (video_pfxs.indexOf(dxName) != -1) {
            type = TYPE_VIDEO;
            playVideo(url);
        }

        if (flash_pfxs.indexOf(dxName) != -1) {
            type = TYPE_FLASH;
            loadSwf(url);
        }

        if (pic_pfxs.indexOf(dxName) != -1) {
            type = TYPE_BITMAP;
            loadBitmap(url);
        }

    }

    /**
     * 停止并卸载当前媒体。
     * @example
     * <listing version="3.0">
     * player.stop();
     * </listing>
     */
    public function stop():void {
        if (_video) {
            _video.destroy();
            _video = null;
        }
        if (_img) {
            removeChild(_img);
            _img.unload();
            _img = null;
        }
        if (_swf) {
            removeChild(_swf);
            _swf.unload();
            _swf = null;
        }
    }

    /**
     * 立即播放视频（从开头）。
     * @example
     * <listing version="3.0">
     * player.playNow();
     * </listing>
     */
    public function playNow():void {
        if (_video) {
            _video.play();
        }
    }

    /**
     * 停止视频（不销毁）。
     * @example
     * <listing version="3.0">
     * player.stopVideo();
     * </listing>
     */
    public function stopVideo():void {
        if (_video) {
            _video.stop();
        }
    }

    /**
     * 切换视频播放 / 暂停。
     * @example
     * <listing version="3.0">
     * player.toggleMovie();
     * </listing>
     */
    public function toggleMovie():void {
        if (_video.playing) {
            _video.pause();
        }
        else {
            _video.play();
        }
    }

    /**
     * 销毁全部资源。
     * @example
     * <listing version="3.0">
     * player.destroy();
     * </listing>
     */
    public function destroy():void {
        type = null;
        _url = null;

        if (_img) {
            try {
                removeChild(_img);
            }
            catch (e:Error) {
            }
            _img.unload();
            _img = null;
        }
        if (_swf) {
            try {
                removeChild(_swf);
            }
            catch (e:Error) {
            }
            if (_swf['unloadAndStop'] != undefined) {
                _swf['unloadAndStop']();
            }
            else {
                _swf.unload();
            }
            _swf = null;
        }
        if (_video) {
            try {
                removeChild(_video);
            }
            catch (e:Error) {
            }
            _video.destroy();
            _video = null;
        }
    }

    /**
     * @private
     */
    private function loadBitmap(v:String):void {
        var l:Loader = new Loader();
        l.contentLoaderInfo.addEventListener(Event.COMPLETE, loadPicComplete);
        l.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onLoadContentFail);
        l.load(new URLRequest(v));
    }

    /**
     * @private
     */
    private function loadSwf(v:String):void {
        _swf = new Loader();
        _swf.contentLoaderInfo.addEventListener(Event.COMPLETE, loadSwfComplete);
        _swf.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onLoadContentFail);
        _swf.scrollRect = new Rectangle(0, 0, _size.x, _size.y);
        addChild(_swf);
        _swf.load(new URLRequest(v));
    }

    /**
     * @private
     */
    private function playVideo(url:String):void {
        _video = new InsVideo(url, _size);
        addChild(_video);
        if (autoPlay) {
            _video.play();
        }
        _video.addEventListener(InsVideo.PLAY_COMPLETE, onVideComplete);
        _video.addEventListener(InsVideo.PLAY_FAIL, onLoadContentFail);
        _video.addEventListener(InsVideo.META_DATA, onLoadContentComplete);
    }

    /**
     * @private
     */
    private function loadPicComplete(e:Event):void {
        var loaderInfo:LoaderInfo = e.currentTarget as LoaderInfo;
        loaderInfo.removeEventListener(Event.COMPLETE, loadPicComplete);
        loaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onLoadContentFail);
        _img = loaderInfo.loader;
        if (lockRatio) {
            if (_img.width > _img.height) {
                _img.width  = _size.x;
                _img.scaleY = _img.scaleX;
                _img.y      = (_size.y - _img.height) / 2;
            }
            else {
                _img.height = _size.y;
                _img.scaleX = _img.scaleY;
                _img.x      = (_size.x - _img.width) / 2;
            }
        }
        else {
            _img.width  = _size.x;
            _img.height = _size.y;
        }
        addChild(_img);
        onLoadContentComplete();
    }

    /**
     * @private
     */
    private function loadSwfComplete(e:Event):void {
        var back:Shape = new Shape();
        back.graphics.beginFill(KyoColor.BLACK, 1);
        back.graphics.drawRect(0, 0, _size.x, _size.y);
        back.graphics.endFill();
        addChild(back);

        var li:LoaderInfo = e.currentTarget as LoaderInfo;

        li.removeEventListener(Event.COMPLETE, loadSwfComplete);
        li.removeEventListener(IOErrorEvent.IO_ERROR, onLoadContentFail);

        var l:Loader  = li.loader;
        var bl:Number = _size.x / li.width;
        var hl:Number = _size.y / li.height;
        var ll:Number = Math.max(bl, hl);
        l.scaleX      = l.scaleY = ll;
        if (l.y < 0) {
            l.y = 0;
        }
        addChild(l);
        onLoadContentComplete();
    }

    /**
     * @private
     */
    private function onVideComplete(e:Event):void {
        dispatchEvent(new Event(EVENT_PLAY_COMPLETE));
        if (_loopPlay) {
            playNow();
        }
    }

    /**
     * @private
     */
    private function onLoadContentComplete(e:Event = null):void {
        dispatchEvent(new Event(EVENT_LOAD_COMPLETE));
    }

    /**
     * @private
     */
    private function onLoadContentFail(e:Event = null):void {
        dispatchEvent(new Event(EVENT_LOAD_FAIL));
    }
}
}

import flash.display.Sprite;
import flash.events.AsyncErrorEvent;
import flash.events.Event;
import flash.events.NetStatusEvent;
import flash.geom.Point;
import flash.media.Video;
import flash.net.NetConnection;
import flash.net.NetStream;
import flash.utils.clearTimeout;
import flash.utils.setTimeout;

/**
 * NetStream 视频播放包装（文件内 internal）。
 */
internal class InsVideo extends Sprite {
    /**
     * 播放完成。
     * @eventType insvideo.play.complete
     */
    public static const PLAY_COMPLETE:String = 'insvideo.play.complete';
    /**
     * 播放失败。
     * @eventType insvideo.play.fail
     */
    public static const PLAY_FAIL:String     = 'insvideo.play.fail';
    /**
     * 元数据就绪。
     * @eventType insvideo.event.metadata
     */
    public static const META_DATA:String     = 'insvideo.event.metadata';

    /**
     * @param url 视频 URL。
     * @param size 显示尺寸。
     */
    public function InsVideo(url:String, size:Point) {
        var flvObject:Object = {};
        flvURL               = url;

        flvNC = new NetConnection();
        flvNC.connect(null);

        flvNS = new NetStream(flvNC);
        flvNS.addEventListener(AsyncErrorEvent.ASYNC_ERROR, videoFail);
        flvNS.addEventListener(NetStatusEvent.NET_STATUS, videoState);
        flvNS.client = flvObject;
        flvNS.play(flvURL);

        flvVideo = new Video(size.x, size.y);
        flvVideo.attachNetStream(flvNS);

        flvNS.pause();

        var obj:Object = {};
        obj.onMetaData = onMetaData;
        flvNS.client   = obj;

        addChild(flvVideo);
    }

    /**
     * 是否在缓冲空时自动 resume（本类内循环逻辑）。
     */
    public var loopPlay:Boolean;
    /**
     * 是否正在播放。
     */
    public var playing:Boolean;
    /**
     * onMetaData 对象。
     */
    public var metadata:Object;
    /** @private */
    private var flvVideo:Video;
    /** @private */
    private var flvURL:String;
    /** @private */
    private var flvNC:NetConnection;
    /** @private */
    private var flvNS:NetStream;
    /** @private */
    private var _siint:int;

    /**
     * 从开头重新播放。
     */
    public function play():void {
        playing = true;

        clearTimeout(_siint);

        flvNS.play(flvURL);
        flvNS.seek(0);

    }

    /**
     * 暂停。
     */
    public function pause():void {
        playing = false;
        flvNS.pause();
    }

    /**
     * 继续。
     */
    public function resume():void {
        playing = true;
        flvNS.resume();
    }

    /**
     * 停止并稍后关闭流。
     */
    public function stop():void {
        playing = false;
        flvNS.pause();
        flvNS.seek(0);
        clearTimeout(_siint);
        _siint = setTimeout(flvNS.close, 1000);
    }

    /**
     * 销毁连接与视频。
     */
    public function destroy():void {
        stop();

        if (flvNC) {
            flvNC.close();
            flvNC = null;
        }

        if (flvNS) {
            flvNS.removeEventListener(AsyncErrorEvent.ASYNC_ERROR, videoFail);
            flvNS.removeEventListener(NetStatusEvent.NET_STATUS, videoState);
            flvNS = null;
        }

        if (flvVideo) {
            try {
                removeChild(flvVideo);
            }
            catch (e:Error) {
            }

            flvVideo.clear();
            flvVideo = null;
        }

    }

    /**
     * @private
     */
    private function onMetaData(obj:Object):void {
        metadata = obj;
        dispatchEvent(new Event(META_DATA));
    }

    /**
     * @private
     */
    private function videoFail(evt:AsyncErrorEvent):void {
        dispatchEvent(new Event(PLAY_FAIL));
    }

    /**
     * @private
     */
    private function videoState(evt:NetStatusEvent):void {
        var code:String = evt.info.code;
        switch (code) {
        case 'NetStream.Play.StreamNotFound':
            dispatchEvent(new Event(PLAY_FAIL));
            break;
        case 'NetStream.Play.Complete':
        case 'NetStream.Buffer.Empty':
            if (loopPlay) {
                resume();
            }
            playing = false;
            dispatchEvent(new Event(PLAY_COMPLETE));
            break;
        }
    }
}
