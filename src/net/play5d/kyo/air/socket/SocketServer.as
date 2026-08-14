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
import flash.events.ProgressEvent;
import flash.events.ServerSocketConnectEvent;
import flash.net.ObjectEncoding;
import flash.net.ServerSocket;
import flash.net.Socket;
import flash.utils.ByteArray;
import flash.utils.Dictionary;

import net.play5d.kyo.air.socket.events.SocketEvent;
import net.play5d.kyo.utils.PacketBuffer;
import net.play5d.kyo.utils.PacketUtils;

/**
 * 接受新客户端时分派。
 * @eventType net.play5d.kyo.air.socket.events.SocketEvent.CLIENT_CONNECT
 */
[Event(name='SocketEvent_CLIENT_CONNECT', type='net.play5d.kyo.air.socket.events.SocketEvent')]
/**
 * 客户端断开时分派。
 * @eventType net.play5d.kyo.air.socket.events.SocketEvent.CLIENT_DIS_CONNECT
 */
[Event(name='SocketEvent_CLIENT_DIS_CONNECT', type='net.play5d.kyo.air.socket.events.SocketEvent')]
/**
 * 收到完整包体时分派。
 * @eventType net.play5d.kyo.air.socket.events.SocketEvent.RECEIVE_DATA
 */
[Event(name='SocketEvent_RECEIVE_DATA', type='net.play5d.kyo.air.socket.events.SocketEvent')]
/**
 * 服务端监听关闭时分派。
 * @eventType net.play5d.kyo.air.socket.events.SocketEvent.CLOSE
 */
[Event(name='SocketEvent_CLOSE', type='net.play5d.kyo.air.socket.events.SocketEvent')]
/**
 * 定长头（short 长度）TCP 服务端（AIR <code>ServerSocket</code>）。
 *
 * <p>每个客户端独立 <code>PacketBuffer</code>，避免多连接交叉拆包。
 * 通常通过单例 <code>I</code> 使用。</p>
 *
 * @see SocketClient
 * @see SocketEvent
 * @see PacketBuffer
 * @see PacketUtils
 * @example
 * <listing version="3.0">
 * SocketServer.I.bind(12345);
 * SocketServer.I.addEventListener(SocketEvent.CLIENT_CONNECT, onClient);
 * </listing>
 */
public class SocketServer extends EventDispatcher {
    /** @private */
    private static var _i:SocketServer;

    /**
     * 单例。
     * @return 全局服务端实例。
     * @example
     * <listing version="3.0">
     * var server:SocketServer = SocketServer.I;
     * </listing>
     */
    public static function get I():SocketServer {
        _i ||= new SocketServer();

        return _i;
    }

    /**
     * 构造服务端（通常通过 <code>I</code> 使用）。
     */

    /**
     * 是否已绑定监听（或仍有业务意义上的连接态）。
     * @default false
     */
    public var connected:Boolean;
    /** @private */
    private var _serverSocket:ServerSocket;
    /** @private Socket → PacketBuffer */
    private var _packetBuffers:Dictionary;
    /** @private */
    private var _clients:Vector.<Socket>;

    /**
     * 当前已连接客户端列表。
     * @return 客户端 Socket 向量。
     */
    public function get clients():Vector.<Socket> {
        return _clients;
    }

    /**
     * 本地监听端口。
     * @return 端口号。
     */
    public function get port():int {
        return _serverSocket.localPort;
    }

    /**
     * 绑定并监听端口。
     * @param port 本地端口。
     * @example
     * <listing version="3.0">
     * SocketServer.I.bind(12345);
     * </listing>
     */
    public function bind(port:int):void {
        close();

        _serverSocket = new ServerSocket();
        _serverSocket.addEventListener(ServerSocketConnectEvent.CONNECT, onClientConnect);
        _serverSocket.addEventListener(Event.CLOSE, onClose);

        _clients       = new Vector.<Socket>();
        _packetBuffers = new Dictionary();

        try {
            _serverSocket.bind(port);
            _serverSocket.listen();
        }
        catch (e:Error) {
            trace('SocketServer.bind failed:', e.message);
        }

        connected = _serverSocket.bound;
    }

    /**
     * 关闭监听并断开全部客户端。
     * @example
     * <listing version="3.0">
     * SocketServer.I.close();
     * </listing>
     */
    public function close():void {
        if (_clients) {
            for each (var c:Socket in _clients) {
                if (c.connected) {
                    c.close();
                }
            }
            _clients = null;
        }

        _packetBuffers = null;

        if (_serverSocket) {
            _serverSocket.close();
            _serverSocket = null;
        }
        connected = false;
    }

    /**
     * 按远端 IP 查找客户端。
     * @param ip 远端地址。
     * @return 匹配的 Socket；无则 <code>null</code>。
     * @example
     * <listing version="3.0">
     * var s:Socket = SocketServer.I.getClientByIP('192.168.1.2');
     * </listing>
     */
    public function getClientByIP(ip:String):Socket {
        for each (var i:Socket in _clients) {
            if (i.remoteAddress == ip) {
                return i;
            }
        }

        return null;
    }

    /**
     * 向全部客户端发送。
     * @param obj 数据。
     * @example
     * <listing version="3.0">
     * SocketServer.I.sendAll({type: 'sync'});
     * </listing>
     */
    public function sendAll(obj:Object):void {
        try {
            if (!_clients || _clients.length == 0) {
                return;
            }
            for (var i:int = 0; i < _clients.length; i++) {
                send(_clients[i], obj);
            }
        }
        catch (error:Error) {
            trace(error.message);
        }
    }

    /**
     * 向指定客户端发送（自动加长度头）。
     * @param client 目标 Socket。
     * @param data <code>ByteArray</code> 或可序列化对象。
     * @example
     * <listing version="3.0">
     * SocketServer.I.send(client, {ok: true});
     * </listing>
     */
    public function send(client:Socket, data:Object):void {
        if (client == null) {
            return;
        }

        var bytes:ByteArray;
        if (data is ByteArray) {
            bytes = PacketUtils.addByteArrayHead(data as ByteArray);
        }
        else {
            bytes = PacketUtils.createByteArrayWithHead(data);
        }

        PacketUtils.compress(bytes);

        client.objectEncoding = ObjectEncoding.AMF3;
        client.writeBytes(bytes, 0, bytes.bytesAvailable);
        client.flush();
    }

    /**
     * JSON 序列化后发送。
     * @param client 目标 Socket。
     * @param data 可被 <code>JSON.stringify</code> 的对象。
     * @example
     * <listing version="3.0">
     * SocketServer.I.sendJson(client, {cmd: 'ping'});
     * </listing>
     */
    public function sendJson(client:Socket, data:Object):void {
        send(client, JSON.stringify(data));
    }

    /**
     * 按 IP 发送字节。
     * @param ip 远端 IP。
     * @param obj 载荷。
     * @example
     * <listing version="3.0">
     * SocketServer.I.sendByIP('192.168.1.2', bytes);
     * </listing>
     */
    public function sendByIP(ip:String, obj:ByteArray):void {
        send(getClientByIP(ip), obj);
    }

    /** @private */
    private function onClientConnect(event:ServerSocketConnectEvent):void {
        var clientSocket:Socket = event.socket;
        clientSocket.addEventListener(ProgressEvent.SOCKET_DATA, onClientSocketData);
        clientSocket.addEventListener(Event.CLOSE, onCloseClient);

        _clients.push(clientSocket);
        _packetBuffers[clientSocket] = new PacketBuffer();
        connected = true;

        var se:SocketEvent = new SocketEvent(SocketEvent.CLIENT_CONNECT);
        se.clientSocket    = clientSocket;
        dispatchEvent(se);
    }

    /** @private */
    private function onClose(e:Event):void {
        if (_serverSocket) {
            _serverSocket.removeEventListener(ServerSocketConnectEvent.CONNECT, onClientConnect);
            _serverSocket.removeEventListener(Event.CLOSE, onClose);
        }

        dispatchEvent(new SocketEvent(SocketEvent.CLOSE));
        connected = false;
    }

    /** @private */
    private function onCloseClient(e:Event):void {
        var closeClient:Socket = e.currentTarget as Socket;

        for (var i:int = 0; i < _clients.length; i++) {
            var client:Socket = _clients[i];
            if (client.remoteAddress == closeClient.remoteAddress && client.remotePort == closeClient.remotePort) {
                _clients.splice(i, 1);
                delete _packetBuffers[client];

                var se:SocketEvent = new SocketEvent(SocketEvent.CLIENT_DIS_CONNECT);
                se.clientSocket    = client;
                dispatchEvent(se);
                break;
            }
        }
    }

    /** @private */
    private function onClientSocketData(event:ProgressEvent):void {
        var client:Socket    = event.currentTarget as Socket;
        var buffer:ByteArray = new ByteArray();
        client.readBytes(buffer, 0, client.bytesAvailable);

        PacketUtils.uncompress(buffer);

        var packetBuffer:PacketBuffer = _packetBuffers[client] as PacketBuffer;
        if (!packetBuffer) {
            packetBuffer           = new PacketBuffer();
            _packetBuffers[client] = packetBuffer;
        }
        packetBuffer.push(buffer);

        var packets:Array = packetBuffer.getPackets();
        for each (var data:ByteArray in packets) {
            var se:SocketEvent = new SocketEvent(SocketEvent.RECEIVE_DATA);
            se.data            = data;
            se.clientSocket    = client;
            dispatchEvent(se);
        }
    }
}
}
