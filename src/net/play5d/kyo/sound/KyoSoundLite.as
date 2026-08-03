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
import flash.net.URLRequest;

/**
 * 轻量一次性播放：传入声音 Class 或 URL 即播。
 *
 * @see #play()
 * @see KyoSoundPlayer
 */
public class KyoSoundLite {
    /**
     * 播放声音。
     * @param sound 声音 <code>Class</code> 或 URL 字符串。
     * @param times 循环次数；默认 1。
     * @example
     * <listing version="3.0">
     * KyoSoundLite.play('hit.mp3');
     * </listing>
     */
    public static function play(sound:Object, times:int = 1):void {
        var s:Sound;
        if (sound is Class) {
            s = new sound();
        }
        if (sound is String) {
            s = new Sound(new URLRequest(sound as String));
        }
        if (s) {
            s.play(0, times);
        }
    }

}
}
