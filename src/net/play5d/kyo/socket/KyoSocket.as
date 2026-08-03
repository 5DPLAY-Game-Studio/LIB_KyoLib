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

package net.play5d.kyo.socket {
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.ProgressEvent;
import flash.events.SecurityErrorEvent;
import flash.net.Socket;
import flash.utils.ByteArray;
import flash.utils.setTimeout;

/**
 * 基于 <code>Socket</code> 的简易连接封装：回调、断线重连与多种发送方式。
 *
 * @see #connect()
 * @see #sendMsg()
 * @see #autoConnect
 */
public class KyoSocket {
    /**
     * 构造函数。
     */
    public function KyoSocket() {
    }

    /**
     * 字符串编码格式。
     * @default UTF-8
     */
    public var charset:String = 'UTF-8';
    /**
     * 断线后是否自动重连。
     * @default false
     */
    public var autoConnect:Boolean;
    /**
     * 自动重连时间间隔（秒）。
     * @default 1
     */
    public var autoConnectGap:int = 1;
    /**
     * 错误回调，参数为错误描述字符串。
     */
    public var on_error:Function;
    /**
     * 连接成功回调，无参数。
     */
    public var on_connect:Function;
    /**
     * 连接关闭回调，无参数。
     */
    public var on_close:Function;
    /**
     * 收到数据回调，参数为 <code>ByteArray</code>。
     */
    public var on_data:Function;
    /** @private */
    private var _socket:Socket;
    /** @private */
    private var _host:String, _port:int;

    /**
     * 是否已连接。
     * @return 连接状态。
     */
    public function get connected():Boolean {
        return _socket.connected;
    }

    /**
     * 连接服务器。
     * @param host 主机；默认 <code>localhost</code>。
     * @param port 端口。
     * @example
     * <listing version="3.0">
     * socket.connect('127.0.0.1', 8080);
     * </listing>
     */
    public function connect(host:String = 'localhost', port:int = 0):void {
        _host = host;
        _port = port;

        _socket = new Socket(host, port);
        _socket.addEventListener(Event.CLOSE, closeHandler);
        _socket.addEventListener(Event.CONNECT, connectHandler);
        _socket.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
        _socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, ercurityErrorHandler);
        _socket.addEventListener(ProgressEvent.SOCKET_DATA, dataHandler);
    }

    /**
     * 发送消息：<code>int</code> 写整型；<code>String</code> 按定长多字节写入。
     * @param msg <code>int</code> 或 <code>String</code>。
     * @param length 字符串定长字节数；默认 32。
     * @example
     * <listing version="3.0">
     * socket.sendMsg('hello', 32);
     * </listing>
     */
    public function sendMsg(msg:*, length:int = 32):void {
        if (!connected) {
            return;
        }
        if (msg is int) {
            _socket.writeInt(msg);
            _socket.flush();
            return;
        }
        if (msg is String) {
            var b:ByteArray = new ByteArray();
            b.writeMultiByte(msg, charset);
            b.length = length;
            sendByteArray(b);
            _socket.flush();
            return;
        }
    }

    /**
     * 发送字节。
     * @param b 数据。
     * @example
     * <listing version="3.0">
     * socket.sendByteArray(ba);
     * </listing>
     */
    public function sendByteArray(b:ByteArray):void {
        if (!_socket.connected) {
            return;
        }
        _socket.writeBytes(b);
        _socket.flush();
    }

    /**
     * 发送 AMF 对象。
     * @param o 对象。
     * @example
     * <listing version="3.0">
     * socket.sendObject({cmd: 1});
     * </listing>
     */
    public function sendObject(o:Object):void {
        if (!_socket.connected) {
            return;
        }
        _socket.writeObject(o);
        _socket.flush();
    }

    /**
     * 在未连接时用上次主机端口重连。
     * @example
     * <listing version="3.0">
     * socket.reConnect();
     * </listing>
     */
    public function reConnect():void {
        if (_socket.connected) {
            return;
        }
        _socket.connect(_host, _port);
    }

    /**
     * @private
     */
    private function onConnectClose():void {
        if (autoConnect) {
            setTimeout(reConnect, autoConnectGap * 1000);
        }
        if (on_close != null) {
            on_close();
        }
    }

    /**
     * @private
     */
    private function closeHandler(e:Event):void {
        trace('连接中断');
        onConnectClose();
    }

    /**
     * @private
     */
    private function connectHandler(e:Event):void {
        trace('连接成功');
        if (on_connect != null) {
            on_connect();
        }
    }

    /**
     * @private
     */
    private function ioErrorHandler(e:IOErrorEvent):void {
        trace('IO错误');
        if (on_error != null) {
            on_error('IO错误');
        }
        onConnectClose();
    }

    /**
     * @private
     */
    private function ercurityErrorHandler(e:SecurityErrorEvent):void {
        trace('安全性错误');
        if (on_error != null) {
            on_error('安全性错误');
        }
        onConnectClose();
    }

    /**
     * @private
     */
    private function dataHandler(e:ProgressEvent):void {
        trace('接收到数据');
        if (on_data != null) {
            var buffer:ByteArray = new ByteArray();
            e.currentTarget.readBytes(buffer, 0, e.currentTarget.bytesAvailable);
            on_data(buffer);
        }
    }

}
}
