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
import flash.media.Sound;
import flash.media.SoundTransform;
import flash.utils.getTimer;

import net.play5d.kyo.utils.KyoRandom;

/**
 * 音效播放单例：支持声道互斥、播放间隔与音量控制。
 *
 * @see #I
 * @see #playSound()
 * @see KyoSoundLite
 */
public class KyoSoundPlayer {
    /** @private */
    private static var _i:KyoSoundPlayer;

    /**
     * 单例。
     * @return 单例实例。
     */
    public static function get I():KyoSoundPlayer {
        _i ||= new KyoSoundPlayer();

        return _i;
    }

    /** @private channelId → InsSound */
    private var _sounds:Object = {};
    /** @private 全局默认音量 */
    private var _defaultValue:Number = 1;
    /** @private channelId=-1 时上次播放时间 */
    private var _lastPlay:int;

    /**
     * 播放声音。
     * @param s 声音对象、<code>Class</code>，或数组（随机取一项）。
     * @param channelId 声道 ID；同 ID 同时仅一路；-1 表示不限声道。
     * @param gap 播放间隔（毫秒），仅 <code>channelId == -1</code> 时有效。
     * @param loops 循环次数。
     * @param volume 音量；-1 时用全局或该声道音量。
     * @param merge 为 <code>true</code> 时覆盖同声道正在播放的声音。
     * @param onComplete 声道播放完成回调；可省略。
     * @example
     * <listing version="3.0">
     * KyoSoundPlayer.I.playSound(HitSnd, 1);
     * </listing>
     */
    public function playSound(
        s         :Object,
        channelId :int = -1,
        gap       :int = 100,
        loops     :int = 0,
        volume    :Number = -1,
        merge     :Boolean = false,
        onComplete:Function = null
    ):void {
        var snd:Sound = getSound(s);
        if (!snd) {
            return;
        }

        if (channelId == -1) {
            if (getTimer() - _lastPlay < gap) {
                return;
            }
            if (volume == -1) {
                volume = _defaultValue;
            }
            snd.play(0, loops, new SoundTransform(volume));
            _lastPlay = getTimer();
            return;
        }

        if (_sounds[channelId]) {
            var c:InsSound = _sounds[channelId] as InsSound;
            if (!merge && c.playing) {
                return;
            }
            if (volume == -1) {
                volume = c.volume;
            }
            c.stop();
        }

        var ins:InsSound = new InsSound(snd);
        ins.play(loops, volume);
        ins.onComplete     = onComplete;
        _sounds[channelId] = ins;
    }

    /**
     * 停止指定声道。
     * @param channelId 声道 ID。
     * @example
     * <listing version="3.0">
     * KyoSoundPlayer.I.stopSound(1);
     * </listing>
     */
    public function stopSound(channelId:int = -1):void {
        var c:InsSound = _sounds[channelId] as InsSound;
        if (c) {
            c.stop();
        }
    }

    /**
     * 停止所有声道声音。
     * @param clean 为 <code>true</code> 时清空声道表。
     * @example
     * <listing version="3.0">
     * KyoSoundPlayer.I.stopAllSounds(true);
     * </listing>
     */
    public function stopAllSounds(clean:Boolean = false):void {
        for each (var i:InsSound in _sounds) {
            i.stop();
        }
        if (clean) {
            _sounds = null;
        }
    }

    /**
     * 指定声道是否正在播放。
     * @param channelId 声道 ID。
     * @return 是否播放中。
     * @example
     * <listing version="3.0">
     * var p:Boolean = KyoSoundPlayer.I.playingSound(1);
     * </listing>
     */
    public function playingSound(channelId:int = -1):Boolean {
        var c:InsSound = _sounds[channelId] as InsSound;
        if (c) {
            return c.playing;
        }

        return false;
    }

    /**
     * 设置音量。
     * @param volume 0~1。
     * @param channelId 声道；-1 时设全局并同步已有声道。
     * @example
     * <listing version="3.0">
     * KyoSoundPlayer.I.setVolume(0.5);
     * </listing>
     */
    public function setVolume(volume:Number, channelId:int = -1):void {
        if (channelId == -1) {
            _defaultValue = volume;
            for each (var i:InsSound in _sounds) {
                i.volume = volume;
            }
            return;
        }

        if (_sounds[channelId]) {
            (_sounds[channelId] as InsSound).volume = volume;
        }
    }

    /**
     * @private
     */
    private static function getSound(s:Object):Sound {
        var snd:Sound;
        if (s is Array) {
            s = KyoRandom.getRandomInArray(s as Array);
        }
        if (s is Class) {
            snd = new s();
        }
        if (s is Sound) {
            snd = s as Sound;
        }

        return snd;
    }
}
}

import flash.events.Event;
import flash.media.Sound;
import flash.media.SoundChannel;
import flash.media.SoundTransform;

/**
 * 单声道播放包装（文件内 internal）。
 * @private
 */
internal class InsSound {
    /**
     * 构造声道包装。
     * @param sound 声音实例。
     */
    public function InsSound(sound:Sound) {
        _sound = sound;
    }

    /**
     * 是否正在播放。
     * @default false
     */
    public var playing:Boolean;
    /**
     * 播放完成回调。
     * @default null
     */
    public var onComplete:Function;
    /** @private */
    private var _channel:SoundChannel;
    /** @private */
    private var _sound:Sound;
    /** @private */
    private var _loop:int;
    /** @private */
    private var _volume:Number;

    /**
     * 当前音量。
     * @return 当前音量。
     */
    public function get volume():Number {
        return _volume;
    }

    /**
     * @private
     */
    public function set volume(v:Number):void {
        _volume = v;
        playSound(_channel.position);
    }

    /**
     * 开始播放。
     * @param loop 循环次数。
     * @param volume 音量。
     * @example
     * <listing version="3.0">
     * ins.play(1, 0.8);
     * </listing>
     */
    public function play(loop:int, volume:Number):void {
        _volume = volume;
        _loop   = loop;
        playSound();
    }

    /**
     * 停止。
     * @example
     * <listing version="3.0">
     * ins.stop();
     * </listing>
     */
    public function stop():void {
        if (_channel) {
            _channel.stop();
        }
        playing = false;
    }

    /**
     * @private
     */
    private function playSound(startTime:Number = 0):void {
        stop();
        playing  = true;
        _channel = _sound.play(startTime, _loop, new SoundTransform(_volume));
        _channel.addEventListener(Event.SOUND_COMPLETE, soundComplete);
    }

    /**
     * @private
     */
    private function soundComplete(e:Event):void {
        _channel.removeEventListener(Event.SOUND_COMPLETE, soundComplete);
        playing = false;
        if (onComplete != null) {
            onComplete();
        }
    }
}
