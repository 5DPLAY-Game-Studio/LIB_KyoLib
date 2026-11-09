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
import flash.media.SoundTransform;
import flash.net.URLRequest;

/**
 * 背景音乐播放单例：支持 URL / Class / Sound，循环、暂停与音量。
 *
 * @see #I
 * @see #play()
 * @see #stop()
 * @author Kyo
 */
public class KyoBGSounder {
    /** @private */
    private static var _i:KyoBGSounder;

    /**
     * 单例。
     * @return 单例实例。
     * @example
     * <listing version="3.0">
     * var bgm:KyoBGSounder = KyoBGSounder.I;
     * </listing>
     */
    public static function get I():KyoBGSounder {
        _i ||= new KyoBGSounder();

        return _i;
    }

    /**
     * 音乐 URL、声音 Class 或 <code>Sound</code> 实例。
     * @default null
     */
    public var sound:Object;
    /**
     * 当前是否处于播放流程中（由 <code>play</code> / <code>stop</code> 置位；<code>pause</code> / <code>resume</code> 不改此标记）。
     * @default false
     */
    public var playing:Boolean;
    /** @private */
    private var _snd:Sound;
    /** @private */
    private var _channel:SoundChannel;
    /** @private */
    private var _soundTransform:SoundTransform = new SoundTransform();
    /** @private */
    private var _channelPausePosition:int;

    /**
     * 音量 0~1。
     * @return 当前音量。
     * @default 1
     */
    public function get volume():Number {
        return _soundTransform.volume;
    }

    /**
     * @private
     */
    public function set volume(value:Number):void {
        _soundTransform.volume = value;
        if (_channel) {
            _channel.soundTransform = _soundTransform;
        }
    }

    /**
     * 播放背景音乐。
     *
     * <p>已经加载过声音时直接返回，须先 <code>stop</code>。交给 <code>Sound.play</code> 的循环次数固定为 1，曲目会先连播两遍；<code>isLoop</code> 为 true 时，这一轮结束后再从头开始。没有声卡时仍把 <code>playing</code> 设为 true。</p>
     *
     * @param snd 为空时使用 <code>sound</code>。
     * @param isLoop 这一轮结束后是否从头再播，默认 true。
     * @example
     * <listing version="3.0">
     * KyoBGSounder.I.play('bgm.mp3');
     * </listing>
     */
    public function play(snd:Object = null, isLoop:Boolean = true):void {
        trace('bgm play');
        if (_snd) {
            return;
        }

        if (!snd) {
            snd = sound;
        }
        if (snd) {
            sound = snd;
        }
        else {
            trace('没有可播放的音乐');
            return;
        }

        if (sound is String) {
            _snd = new Sound(new URLRequest(sound as String));
        }
        if (sound is Class) {
            _snd = new sound();
        }
        if (sound is Sound) {
            _snd = sound as Sound;
        }

        playSound(0, isLoop);
        playing = true;
    }

    /**
     * 停止并关闭当前音乐。
     *
     * <p>嵌入或已下载完成的声音 <code>close</code> 会抛 2029，此处忽略。</p>
     *
     * @example
     * <listing version="3.0">
     * KyoBGSounder.I.stop();
     * </listing>
     */
    public function stop():void {
        trace('bgm stop');
        if (_channel) {
            _channel.stop();
            _channel = null;
        }
        if (_snd) {
            try {
                _snd.close();
            }
            catch (e:Error) {
                if (e.errorID != 2029) {
                    trace('KyoBGSounder', e);
                }
            }
            _snd = null;
        }
        playing = false;
    }

    /**
     * 暂停，记录播放位置。
     * @example
     * <listing version="3.0">
     * KyoBGSounder.I.pause();
     * </listing>
     */
    public function pause():void {
        trace('bgm pause');
        if (_channel) {
            _channelPausePosition = _channel.position;
            _channel.stop();
        }
    }

    /**
     * 从暂停位置继续播放。
     *
     * <p>会按循环方式重挂完成监听，即使当初 <code>play</code> 没有要求循环。</p>
     *
     * @example
     * <listing version="3.0">
     * KyoBGSounder.I.resume();
     * </listing>
     */
    public function resume():void {
        trace('bgm resume');
        if (_channel) {
            playSound(_channelPausePosition);
        }
    }

    /**
     * 播放中则停止，否则播放。
     *
     * <p>只看 <code>playing</code>。暂停后标记仍为 true，此时会 <code>stop</code> 而不是继续。</p>
     *
     * @example
     * <listing version="3.0">
     * KyoBGSounder.I.toggle();
     * </listing>
     */
    public function toggle():void {
        if (playing) {
            stop();
        }
        else {
            play();
        }
    }

    /**
     * @private
     */
    private function playSound(position:int = 0, isLoop:Boolean = true):void {
        if (!_snd) {
            return;
        }

        _channel = _snd.play(position, 1, _soundTransform);

        // 如没有声卡驱动，_channel 将返回 null
        if (!_channel) {
            return;
        }

        _channel.removeEventListener(Event.SOUND_COMPLETE, playCompleteHandler);
        if (isLoop) {
            _channel.addEventListener(Event.SOUND_COMPLETE, playCompleteHandler);
        }
    }

    /**
     * @private
     */
    private function playCompleteHandler(e:Event):void {
        if (_channel) {
            _channel.removeEventListener(Event.SOUND_COMPLETE, playCompleteHandler);
            _channel = null;
        }
        playSound(0);
    }
}
}
