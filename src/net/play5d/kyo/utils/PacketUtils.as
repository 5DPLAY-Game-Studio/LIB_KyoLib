/*
 * Copyright (C) 2021-2026, 5DPLAY Game Studio
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

package net.play5d.kyo.utils {
import flash.utils.ByteArray;

/**
 * Socket 定长头（short 长度）封包工具。
 *
 * @see PacketBuffer
 * @see #createByteArrayWithHead()
 * @see #addByteArrayHead()
 */
public class PacketUtils {
    /**
     * 将任意可 <code>writeObject</code> 的数据写成带 2 字节长度头的包。
     * @param data 载荷。
     * @return 从头起可读的 <code>ByteArray</code>。
     * @example
     * <listing version="3.0">
     * var ba:ByteArray = PacketUtils.createByteArrayWithHead(msg);
     * </listing>
     */
    public static function createByteArrayWithHead(data:*):ByteArray {
        var byte:ByteArray = new ByteArray();

        byte.position = 2;
        byte.writeObject(data);

        byte.position = 0;
        byte.writeShort(byte.bytesAvailable - 2);

        byte.position = 0;

        return byte;
    }

    /**
     * 为已有字节前插入 2 字节长度头。
     * @param byte 原载荷。
     * @return 新包；长度为负时返回 <code>null</code>。
     * @example
     * <listing version="3.0">
     * var pkt:ByteArray = PacketUtils.addByteArrayHead(payload);
     * </listing>
     */
    public static function addByteArrayHead(byte:ByteArray):ByteArray {
        byte.position = 0;
        var len:int   = byte.bytesAvailable;
        if (len < 0) {
            return null;
        }

        var newByte:ByteArray = new ByteArray();
        newByte.writeShort(len);
        newByte.writeBytes(byte, 0, byte.bytesAvailable);
        newByte.position = 0;

        return newByte;
    }

    /**
     * 压缩占位（历史接口；当前为空实现）。
     * @param byte 待压缩字节。
     * @example
     * <listing version="3.0">
     * PacketUtils.compress(ba);
     * </listing>
     */
    public static function compress(byte:ByteArray):void {
    }

    /**
     * 解压占位（历史接口；当前为空实现）。
     * @param byte 待解压字节。
     * @example
     * <listing version="3.0">
     * PacketUtils.uncompress(ba);
     * </listing>
     */
    public static function uncompress(byte:ByteArray):void {
    }

}
}
