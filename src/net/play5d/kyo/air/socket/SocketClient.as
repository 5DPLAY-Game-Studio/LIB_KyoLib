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

package net.play5d.kyo.air.socket {
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IOErrorEvent;
import flash.events.ProgressEvent;
import flash.net.ObjectEncoding;
import flash.net.Socket;
import flash.utils.ByteArray;

import net.play5d.kyo.air.socket.events.SocketEvent;
import net.play5d.kyo.utils.PacketBuffer;
import net.play5d.kyo.utils.PacketUtils;

/**
 * 定长头（short 长度）TCP 客户端，配合 <code>PacketBuffer</code> 拆包。
 *
 * <p>基于 <code>flash.net.Socket</code>；与 AIR 服务端 <code>SocketServer</code> 成对使用。</p>
 *
 * @see SocketServer
 * @see PacketBuffer
 * @see PacketUtils
 */
public class SocketClient extends EventDispatcher {
    /**
     * 构造客户端并注册底层 Socket 事件。
     */
    public function SocketClient() {
        _clientSocket                = new Socket();
        _clientSocket.objectEncoding = ObjectEncoding.AMF3;
        _clientSocket.addEventListener(Event.CONNECT, onConnect);
        _clientSocket.addEventListener(Event.CLOSE, onClose);
        _clientSocket.addEventListener(IOErrorEvent.IO_ERROR, onError);
        _clientSocket.addEventListener(ProgressEvent.SOCKET_DATA, onSocketData);

        _packetBuffer = new PacketBuffer();
    }

    /**
     * 是否已连接。
     */
    public var isConnected:Boolean;
    /** @private */
    private var _clientSocket:Socket;
    /** @private */
    private var _packetBuffer:PacketBuffer;

    /**
     * 远端地址描述。
     * @return <code>ip:port</code>。
     */
    public function getSocketServer():String {
        return _clientSocket.remoteAddress + ':' + _clientSocket.remotePort;
    }

    /**
     * 连接服务器。
     * @param host 主机。
     * @param port 端口。
     * @example
     * <listing version="3.0">
     * client.connect('127.0.0.1', 12345);
     * </listing>
     */
    public function connect(host:String, port:int):void {
        _clientSocket.connect(host, port);
    }

    /**
     * 断开连接。
     * @example
     * <listing version="3.0">
     * client.close();
     * </listing>
     */
    public function close():void {
        try {
            _clientSocket.close();
        }
        catch (e:Error) {
            trace(e);
        }
    }

    /**
     * 发送对象或原始字节（自动加长度头）。
     * @param msg <code>ByteArray</code> 或可 <code>writeObject</code> 的数据。
     */
    public function send(msg:Object):void {
        try {
            if (_clientSocket == null || !_clientSocket.connected) {
                return;
            }

            var bytes:ByteArray;
            if (msg is ByteArray) {
                bytes = PacketUtils.addByteArrayHead(msg as ByteArray);
            }
            else {
                bytes = PacketUtils.createByteArrayWithHead(msg);
            }
            if (!bytes) {
                return;
            }

            PacketUtils.compress(bytes);
            _clientSocket.writeBytes(bytes, 0, bytes.bytesAvailable);
            _clientSocket.flush();
        }
        catch (error:Error) {
            trace(error.message);
        }
    }

    /**
     * 将对象 JSON 序列化后发送。
     * @param msg 可被 <code>JSON.stringify</code> 的对象。
     */
    public function sendJSON(msg:Object):void {
        send(JSON.stringify(msg));
    }

    /** @private */
    private function onConnect(event:Event):void {
        isConnected = true;
        dispatchEvent(new SocketEvent(SocketEvent.CLIENT_CONNECT));
    }

    /** @private */
    private function onClose(e:Event):void {
        isConnected = false;
        dispatchEvent(new SocketEvent(SocketEvent.CLOSE));
    }

    /** @private */
    private function onSocketData(e:ProgressEvent):void {
        var buffer:ByteArray = new ByteArray();
        _clientSocket.readBytes(buffer, 0, _clientSocket.bytesAvailable);

        PacketUtils.uncompress(buffer);
        _packetBuffer.push(buffer);

        var packets:Array = _packetBuffer.getPackets();
        for each (var data:ByteArray in packets) {
            var se:SocketEvent = new SocketEvent(SocketEvent.RECEIVE_DATA);
            se.data            = data;
            dispatchEvent(se);
        }
    }

    /** @private */
    private function onError(e:IOErrorEvent):void {
        isConnected        = false;
        var se:SocketEvent = new SocketEvent(SocketEvent.ERROR);
        se.error           = e.toString();
        dispatchEvent(se);
    }
}
}
