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
import flash.display.Stage;
import flash.events.KeyboardEvent;

/**
 * Stage 键盘事件多监听分发。
 *
 * @see #initlize()
 * @see #listen()
 */
public class KeyBoarder {

    /** @private */
    private static var _inited:Boolean;

    /** @private */
    private static var _stage:Stage;

    /** @private */
    private static var _keyHandlers:Vector.<Function> = new Vector.<Function>();

    /**
     * 绑定 Stage 并开始监听 KEY_DOWN / KEY_UP（仅首次有效）。
     * @param stage 舞台。
     */
    public static function initlize(stage:Stage):void {
        if (_inited) {
            return;
        }

        _inited = true;

        _stage = stage;
        stage.addEventListener(KeyboardEvent.KEY_DOWN, keyBoardHandler);
        stage.addEventListener(KeyboardEvent.KEY_UP, keyBoardHandler);
    }

    /**
     * 将焦点设回 Stage。
     */
    public static function focus():void {
        if (!_inited) {
            return;
        }
        _stage.focus = _stage;
    }

    /**
     * 注册键盘回调（签名接收 <code>KeyboardEvent</code>）。
     * @param handler 回调。
     */
    public static function listen(handler:Function):void {
        if (!_inited) {
            return;
        }
        if (_keyHandlers.indexOf(handler) == -1) {
            _keyHandlers.push(handler);
        }
    }

    /**
     * 取消注册。
     * @param handler 先前注册的回调。
     */
    public static function unListen(handler:Function):void {
        if (!_inited) {
            return;
        }
        if (_keyHandlers.indexOf(handler) != -1) {
            _keyHandlers.splice(_keyHandlers.indexOf(handler), 1);
        }
    }

    /** @private */
    private static function keyBoardHandler(e:KeyboardEvent):void {
        if (!_inited) {
            return;
        }
        var i:int = 0;
        for (i = 0; i < _keyHandlers.length; i++) {
            _keyHandlers[i](e);
        }
    }

}
}
