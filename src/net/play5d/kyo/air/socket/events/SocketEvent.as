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

package net.play5d.kyo.air.socket.events {
import flash.events.Event;
import flash.net.Socket;
import flash.utils.ByteArray;

/**
 * 定长头 Socket 客户端 / 服务端派发的事件。
 *
 * <p>载荷经 <code>PacketBuffer</code> 拆出完整包后写入 <code>data</code>（不含 2 字节长度头）。</p>
 *
 * @see net.play5d.kyo.air.socket.SocketClient
 * @see net.play5d.kyo.air.socket.SocketServer
 */
public class SocketEvent extends Event {
    /**
     * <code>CLIENT_CONNECT</code> 事件的 <code>type</code> 属性值。
     * <p>客户端连上服务端，或服务端接受新客户端时派发。</p>
     * @eventType SocketEvent_CLIENT_CONNECT
     */
    public static const CLIENT_CONNECT:String = 'SocketEvent_CLIENT_CONNECT';
    /**
     * <code>CLIENT_DIS_CONNECT</code> 事件的 <code>type</code> 属性值。
     * <p>服务端侧检测到客户端断开时派发。</p>
     * @eventType SocketEvent_CLIENT_DIS_CONNECT
     */
    public static const CLIENT_DIS_CONNECT:String = 'SocketEvent_CLIENT_DIS_CONNECT';
    /**
     * <code>RECEIVE_DATA</code> 事件的 <code>type</code> 属性值。
     * <p>收到完整包体时派发。</p>
     * @eventType SocketEvent_RECEIVE_DATA
     */
    public static const RECEIVE_DATA:String = 'SocketEvent_RECEIVE_DATA';
    /**
     * <code>CLOSE</code> 事件的 <code>type</code> 属性值。
     * <p>连接关闭时派发。</p>
     * @eventType SocketEvent_CLOSE
     */
    public static const CLOSE:String = 'SocketEvent_CLOSE';
    /**
     * <code>ERROR</code> 事件的 <code>type</code> 属性值。
     * <p>连接错误时派发。</p>
     * @eventType SocketEvent_ERROR
     */
    public static const ERROR:String = 'SocketEvent_ERROR';

    /**
     * 构造 Socket 事件。
     * @param type 事件类型。
     * @param bubbles 是否冒泡。
     * @param cancelable 是否可取消。
     * @example
     * <listing version="3.0">
     * var e:SocketEvent = new SocketEvent(SocketEvent.RECEIVE_DATA);
     * </listing>
     */
    public function SocketEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false) {
        super(type, bubbles, cancelable);
    }

    /**
     * 相关客户端 Socket（服务端事件时有值）。
     * @default null
     */
    public var clientSocket:Socket;
    /**
     * 收到的包体字节（不含长度头）。
     * @default null
     */
    public var data:ByteArray;
    /**
     * 错误描述（<code>ERROR</code> 时）。
     * @default null
     */
    public var error:String;

    /**
     * 将 <code>data</code> 按 AMF 读为 Object。
     * @return 反序列化结果；失败时为 <code>null</code>。
     * @example
     * <listing version="3.0">
     * var obj:Object = e.getDataObject();
     * </listing>
     */
    public function getDataObject():Object {
        if (!data) {
            return null;
        }
        data.position = 0;
        try {
            return data.readObject();
        }
        catch (e:Error) {
            trace('SocketEvent.getDataObject :: ', e);
        }

        return null;
    }
}
}
