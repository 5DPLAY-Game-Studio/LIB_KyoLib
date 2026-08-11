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
 * Socket 定长头（short 长度）流式拆包缓冲。
 *
 * <p>与 <code>PacketUtils</code> 组包格式对应：2 字节大端长度 + 载荷。
 * 将零散 <code>SOCKET_DATA</code> 写入后，用 <code>getPackets()</code> 取出完整包体。</p>
 *
 * @see PacketUtils
 * @see #push()
 * @see #getPackets()
 */
public class PacketBuffer {
    /**
     * 构造空缓冲。
     */
    public function PacketBuffer() {
    }

    /** @private 未拆完的累计字节 */
    private var _buf:ByteArray = new ByteArray();

    /**
     * 追加收到的字节。
     * <p>缓冲为空（含 <code>clear</code> / 拆包耗尽后）时会直接引用传入的 <code>ByteArray</code>，之后对该对象的写入会影响缓冲。</p>
     * @param ba 本次读到的数据。
     * @example
     * <listing version="3.0">
     * buffer.push(socketBytes);
     * </listing>
     */
    public function push(ba:ByteArray):void {
        if (_buf == null) {
            _buf = ba;
        }
        else {
            _buf.position = _buf.length;
            _buf.writeBytes(ba);
        }
    }

    /**
     * 从缓冲中拆出当前所有完整包体（不含长度头）。
     * @return 包体 <code>ByteArray</code> 数组；不足一整包时保留残片并返回已拆出的部分。
     * @example
     * <listing version="3.0">
     * var packets:Array = buffer.getPackets();
     * </listing>
     */
    public function getPackets():Array {
        var ps:Array = [];
        _buf.position = 0;

        // 至少要有 2 字节长度头才尝试拆包
        while (_buf.bytesAvailable >= 2) {
            var len:uint = _buf.readShort();

            // 载荷不足：回退长度头，保留残片待下次再拆
            if (_buf.bytesAvailable < len) {
                _buf.position -= 2;
                var rest:ByteArray = new ByteArray();
                rest.writeBytes(_buf, _buf.position);
                _buf = rest;

                return ps;
            }

            var body:ByteArray = new ByteArray();
            _buf.readBytes(body, 0, len);
            body.position = 0;
            ps.push(body);
        }

        if (_buf.bytesAvailable <= 0) {
            _buf = null;
        }

        return ps;
    }

    /**
     * 清空缓冲。
     * @example
     * <listing version="3.0">
     * buffer.clear();
     * </listing>
     */
    public function clear():void {
        _buf = null;
    }
}
}
