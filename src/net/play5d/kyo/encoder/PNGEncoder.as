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

package net.play5d.kyo.encoder {
import flash.display.BitmapData;
import flash.utils.ByteArray;

/**
 * 将 <code>BitmapData</code> 编码为 PNG（IHDR / IDAT / IEND）。
 *
 * @see #encode()
 */
public class PNGEncoder {
    /** @private CRC 查找表 */
    private static var _crcTable:Array;
    /** @private 是否已初始化 CRC 表 */
    private static var _crcTableComputed:Boolean = false;

    /**
     * 将位图编码为 PNG 字节流。
     * @param img 源位图。
     * @return PNG 数据的 <code>ByteArray</code>。
     * @example
     * <listing version="3.0">
     * var bytes:ByteArray = PNGEncoder.encode(bd);
     * </listing>
     */
    public static function encode(img:BitmapData):ByteArray {
        var png:ByteArray = new ByteArray();
        png.writeUnsignedInt(0x89504e47);
        png.writeUnsignedInt(0x0D0A1A0A);

        var ihdr:ByteArray = new ByteArray();
        ihdr.writeInt(img.width);
        ihdr.writeInt(img.height);
        ihdr.writeUnsignedInt(0x08060000); // 32bit RGBA
        ihdr.writeByte(0);
        writeChunk(png, 0x49484452, ihdr);

        var idat:ByteArray = new ByteArray();
        for (var i:int = 0; i < img.height; i++) {
            idat.writeByte(0); // no filter

            var p:uint;
            var j:int;
            if (!img.transparent) {
                for (j = 0; j < img.width; j++) {
                    p = img.getPixel(j, i);
                    idat.writeUnsignedInt(uint(((p & 0xFFFFFF) << 8) | 0xFF));
                }
            }
            else {
                for (j = 0; j < img.width; j++) {
                    p = img.getPixel32(j, i);
                    idat.writeUnsignedInt(uint(((p & 0xFFFFFF) << 8) | (p >>> 24)));
                }
            }
        }
        idat.compress();
        writeChunk(png, 0x49444154, idat);
        writeChunk(png, 0x49454E44, null);

        return png;
    }

    /**
     * @private 写入带 CRC 的 PNG chunk。
     */
    private static function writeChunk(png:ByteArray, type:uint, data:ByteArray):void {
        if (!_crcTableComputed) {
            _crcTableComputed = true;
            _crcTable         = [];

            var c:uint;
            for (var n:uint = 0; n < 256; n++) {
                c = n;
                for (var k:uint = 0; k < 8; k++) {
                    if (c & 1) {
                        c = uint(uint(0xedb88320) ^ uint(c >>> 1));
                    }
                    else {
                        c = uint(c >>> 1);
                    }
                }
                _crcTable[n] = c;
            }
        }

        var len:uint = data != null ? data.length : 0;
        png.writeUnsignedInt(len);

        var p:uint = png.position;
        png.writeUnsignedInt(type);
        if (data != null) {
            png.writeBytes(data);
        }

        var e:uint   = png.position;
        png.position = p;
        c            = 0xffffffff;
        for (var i:int = 0; i < (e - p); i++) {
            c = uint(_crcTable[(c ^ png.readUnsignedByte()) & uint(0xff)] ^ uint(c >>> 8));
        }
        c            = uint(c ^ uint(0xffffffff));
        png.position = e;
        png.writeUnsignedInt(c);
    }
}
}
