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
import flash.utils.ByteArray;

/**
 * 从压缩音频字节（分块）加载的 <code>Sound</code>。
 *
 * @see #loadBytes()
 */
public class BytesSound extends Sound {
    /**
     * @param bytes 可选压缩音频数据；非空则立即 <code>loadBytes</code>。
     */
    public function BytesSound(bytes:ByteArray = null) {
        super(null, null);
        if (bytes) {
            loadBytes(bytes);
        }
    }

    /**
     * 按最多 40KB 一块调用 <code>loadCompressedDataFromByteArray</code>，完成后 <code>clear</code> 源字节。
     * @param v 压缩音频字节。
     * @example
     * <listing version="3.0">
     * var s:BytesSound = new BytesSound();
     * s.loadBytes(ba);
     * </listing>
     */
    public function loadBytes(v:ByteArray):void {
        v.position = 0;

        while (v.bytesAvailable > 0) {
            var chunk:ByteArray = new ByteArray();
            var len:uint        = Math.min(v.bytesAvailable, 40 * 1024);
            v.readBytes(chunk, 0, len);
            loadCompressedDataFromByteArray(chunk, chunk.bytesAvailable);
        }

        v.clear();
    }
}
}
