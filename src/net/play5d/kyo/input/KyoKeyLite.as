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

package net.play5d.kyo.input {
import flash.display.Stage;
import flash.events.KeyboardEvent;

/**
 * 轻量级全局按键状态：激活后可查询某 keyCode 是否按下。
 *
 * @see #active()
 * @see #isDown()
 * @see KyoKeyInput
 */
public class KyoKeyLite {
    /**
     * 为 <code>true</code> 时 trace 按下 / 抬起的 keyCode。
     * @default false
     */
    public static var debug:Boolean = false;
    /** @private */
    private static var _stage:Stage;
    /** @private 当前按下的 keyCode 集合 */
    private static var _keyDowning:Object;

    /**
     * 在指定 Stage 上注册键盘监听。
     * @param stage 舞台；为 <code>null</code> 时抛错。
     * @throws Error stage 为空。
     * @example
     * <listing version="3.0">
     * KyoKeyLite.active(stage);
     * </listing>
     * @see #off()
     * @see #isDown()
     */
    public static function active(stage:Stage):void {
        _stage = stage;

        if (!_stage) {
            throw new Error('stage is null!');
            return;
        }

        _keyDowning = {};
        stage.addEventListener(KeyboardEvent.KEY_DOWN, keyHandler);
        stage.addEventListener(KeyboardEvent.KEY_UP, keyHandler);
    }

    /**
     * 移除键盘监听。
     * @example
     * <listing version="3.0">
     * KyoKeyLite.off();
     * </listing>
     */
    public static function off():void {
        if (!_stage) {
            return;
        }
        _stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyHandler);
        _stage.removeEventListener(KeyboardEvent.KEY_UP, keyHandler);
    }

    /**
     * 查询指定 keyCode 是否按下。
     * @param code 键盘 keyCode。
     * @return 是否按下。
     * @throws Error 未先调用 <code>active</code>。
     * @example
     * <listing version="3.0">
     * var down:Boolean = KyoKeyLite.isDown(KyoKeyCode.A.code);
     * </listing>
     */
    public static function isDown(code:uint):Boolean {
        if (!_keyDowning) {
            throw new Error('此类尚未激活，需要先调用active方法!');
            return false;
        }
        return _keyDowning[code] != null;
    }

    /**
     * @private 更新按下表。
     */
    private static function keyHandler(e:KeyboardEvent):void {
        var code:uint = e.keyCode;
        if (e.type == KeyboardEvent.KEY_DOWN) {
            _keyDowning[code] = 1;
        }
        if (e.type == KeyboardEvent.KEY_UP) {
            delete _keyDowning[code];
        }
        if (debug) {
            trace(e.type + ' : ' + code);
        }
    }

}
}
