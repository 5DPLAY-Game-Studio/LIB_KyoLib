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

package net.play5d.kyo.sound {
import flash.events.Event;
import flash.media.Sound;
import flash.media.SoundChannel;
import flash.net.URLRequest;

import net.play5d.kyo.utils.KyoArrayUtils;
import net.play5d.kyo.utils.KyoRandom;

/**
 * 基于 URL 列表的 MP3 播放器，支持多种播放模式与上一曲 / 下一曲。
 *
 * @see #playMode
 * @see #list
 * @see #play()
 */
public class KyoMp3Player {
    /** 列表循环。 */
    public static const MODE_ALL_LOOP:String = 'all_loop_mode';
    /** 单曲循环。 */
    public static const MODE_ONE_LOOP:String = 'one_loop_mode';
    /** 列表播完停止。 */
    public static const MODE_ALL_ONCE:String = 'all_once_mode';
    /** 单曲播完停止。 */
    public static const MODE_ONE_ONCE:String = 'one_once_mode';
    /** 随机下一曲。 */
    public static const MODE_RANDOM:String   = 'random_mode';

    /**
     * 构造函数。
     */
    public function KyoMp3Player() {
    }

    /**
     * 播放模式，见 <code>MODE_ALL_LOOP</code> 等常量。
     */
    public var playMode:String;
    /**
     * 曲目 URL 列表。
     */
    public var list:Array = [];
    /** @private */
    private var _sound:Sound;
    /** @private */
    private var _channel:SoundChannel;
    /** @private */
    private var _current:String;
    /** @private */
    private var _pausedPos:int;

    /**
     * 播放指定 URL；为空时尝试从暂停位置恢复，或播放列表首项。
     * @param v MP3 URL；可省略。
     * @throws Error 列表为空且无法确定播放目标。
     * @example
     * <listing version="3.0">
     * player.play('a.mp3');
     * </listing>
     */
    public function play(v:String = null):void {
        if (!v) {
            if (_pausedPos > 0) {
                _channel = _sound.play(_pausedPos);
                return;
            }
            if (list && list.length > 0) {
                v = list[0];
            }
            else {
                throw new Error('mp3 list 为空，不能播放音乐');
            }
        }

        stop();
        _pausedPos = 0;
        _current   = v;
        KyoArrayUtils.pushIfAbsent(list, v);

        _sound   = new Sound(new URLRequest(v));
        _channel = _sound.play();
        _channel.addEventListener(Event.SOUND_COMPLETE, onSoundComplete);

    }

    /**
     * 停止当前播放。
     * @example
     * <listing version="3.0">
     * player.stop();
     * </listing>
     */
    public function stop():void {
        if (_channel) {
            _channel.removeEventListener(Event.SOUND_COMPLETE, onSoundComplete);
            _channel.stop();
            _channel = null;
            _sound   = null;
        }
    }

    /**
     * 暂停并记录位置。
     * @example
     * <listing version="3.0">
     * player.pause();
     * </listing>
     */
    public function pause():void {
        _pausedPos = _channel.position;
        _channel.stop();
    }

    /**
     * 播放列表下一曲。
     * @param loop 到末尾时是否回到第一首。
     * @example
     * <listing version="3.0">
     * player.next();
     * </listing>
     */
    public function next(loop:Boolean = true):void {
        if (!list) {
            return;
        }
        var id:int = list.indexOf(_current) + 1;
        if (id >= list.length) {
            if (loop) {
                id = 0;
            }
            else {
                stop();
                return;
            }
        }
        play(list[id]);
    }

    /**
     * 播放列表上一曲。
     * @param loop 到开头时是否跳到最后一首。
     * @example
     * <listing version="3.0">
     * player.prev();
     * </listing>
     */
    public function prev(loop:Boolean = true):void {
        if (!list) {
            return;
        }
        var id:int = list.indexOf(_current) - 1;
        if (id < 0) {
            if (loop) {
                id = list.length - 1;
            }
            else {
                stop();
                return;
            }
        }
        play(list[id]);
    }

    /**
     * @private 按 playMode 决定下一动作。
     */
    private function onSoundComplete(e:Event):void {
        _channel.removeEventListener(Event.SOUND_COMPLETE, onSoundComplete);

        switch (playMode) {
        case MODE_ALL_LOOP:
            next();
            break;
        case MODE_ALL_ONCE:
            next(false);
            break;
        case MODE_ONE_LOOP:
            play(_current);
            break;
        case MODE_ONE_ONCE:
            stop();
            break;
        case MODE_RANDOM:
            play(KyoRandom.getRandomInArray(list));
            break;
        }
    }

}
}
