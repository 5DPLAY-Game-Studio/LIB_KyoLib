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
import flash.utils.getTimer;

/**
 * 可映射的键盘输入管理：按下态、按过判定、连招顺序与回调。
 *
 * @see KyoKeyVO
 * @see KyoKeyLite
 * @see #mappingKeyCode()
 * @see #turnOn()
 */
public class KyoKeyInput {
    /**
     * @param stage 侦听键盘事件的舞台。
     */
    public function KyoKeyInput(stage:Stage) {
        this.stage = stage;
    }

    /**
     * 舞台引用。
     */
    public var stage:Stage;
    /**
     * 是否记录连招顺序队列。
     * @default true
     */
    public var orderKeyAble:Boolean = true;
    /**
     * 连续按键队列的最大值。
     * @default 10
     */
    public var maxOrderKeyLength:int = 10;
    /**
     * 连续按键时间限定（毫秒）；超时则清空队列。
     * @default 200
     */
    public var orderKeyDuration:int = 200;
    /** @private */
    private var _orderKeys:Array = [];
    /** @private */
    private var _lastDownTime:int;
    /** @private */
    private var _downCodes:Object = {};
    /** @private name → KyoKeyVO */
    private var _keys:Object = {};
    /** @private code → KyoKeyVO */
    private var _map:Object;
    /** @private */
    private var _isOn:Boolean;
    /** @private */
    private var _downF:Function;
    /** @private */
    private var _upF:Function;

    /**
     * 批量设置按键映射（先清空再添加）。
     * @param array 元素为 <code>{name:String, code:int}</code> 或 <code>KyoKeyVO</code>。
     * @example
     * <listing version="3.0">
     * input.mappingKeyCode([KyoKeyCode.A, KyoKeyCode.S]);
     * </listing>
     * @see #addMappingKeyCodeVO()
     * @see #clearMappingKeyCode()
     */
    public function mappingKeyCode(array:Array):void {
        clearMappingKeyCode();
        for each(var i:Object in array) {
            addMappingKeyCodeVO(i);
        }
        updateMapping();
    }

    /**
     * 增加一条按键映射。
     * @param o <code>{name:String, code:int}</code> 或 <code>KyoKeyVO</code>。
     * @example
     * <listing version="3.0">
     * input.addMappingKeyCodeVO(KyoKeyCode.SPACE);
     * </listing>
     */
    public function addMappingKeyCodeVO(o:Object):void {
        var k:KyoKeyVO;
        if (o is KyoKeyVO) {
            k = o as KyoKeyVO;
        }
        else {
            k = new KyoKeyVO(o.name, o.code);
        }
        _keys[k.name] = k;

        updateMapping();
    }

    /**
     * 移除一条按键映射。
     * @param o 键名 <code>String</code> 或 <code>KyoKeyVO</code>。
     * @example
     * <listing version="3.0">
     * input.removeMappingKeyCodeVO('A');
     * </listing>
     */
    public function removeMappingKeyCodeVO(o:Object):void {
        var s:String;
        if (o is String) {
            s = o as String;
        }
        if (o is KyoKeyVO) {
            s = (o as KyoKeyVO).name;
        }
        if (s && _keys[s]) {
            delete _keys[s];
            updateMapping();
        }
    }

    /**
     * 清空全部映射。
     * @example
     * <listing version="3.0">
     * input.clearMappingKeyCode();
     * </listing>
     */
    public function clearMappingKeyCode():void {
        _keys = {};
        _map  = {};
    }

    /**
     * 检查映射表是否均非 null。
     * @return 全部有效为 <code>true</code>。
     * @example
     * <listing version="3.0">
     * var ok:Boolean = input.checkOK();
     * </listing>
     */
    public function checkOK():Boolean {
        for (var i:String in _keys) {
            if (_keys[i] == null) {
                return false;
            }
        }
        return true;
    }

    /**
     * 导出当前映射为 name→code 对象。
     * @return 键名到 keyCode 的字典。
     * @example
     * <listing version="3.0">
     * var o:Object = input.printKeys();
     * </listing>
     */
    public function printKeys():Object {
        var o:Object = {};
        for each(var i:KyoKeyVO in _keys) {
            o[i.name] = i.code;
        }
        return o;
    }

    /**
     * 开启按键侦听。
     * @throws Error stage 为 null。
     * @example
     * <listing version="3.0">
     * input.turnOn();
     * </listing>
     * @see #turnOff()
     */
    public function turnOn():void {
        if (_isOn) {
            return;
        }
        _isOn = true;
        if (stage == null) {
            throw new Error('stage 不能为 null');
        }
        stage.addEventListener(KeyboardEvent.KEY_DOWN, keyHandler);
        stage.addEventListener(KeyboardEvent.KEY_UP, keyHandler);
    }

    /**
     * 关闭按键侦听并清空连招队列。
     * @example
     * <listing version="3.0">
     * input.turnOff();
     * </listing>
     */
    public function turnOff():void {
        _isOn      = false;
        _orderKeys = [];
        stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyHandler);
        stage.removeEventListener(KeyboardEvent.KEY_UP, keyHandler);
    }

    /**
     * 按映射键名判断是否全部按下。
     * @param params 一个或多个键名（映射表中的 name）。
     * @return 全部按下为 <code>true</code>。
     * @example
     * <listing version="3.0">
     * if (input.isDownKey('A', 'S')) { }
     * </listing>
     */
    public function isDownKey(...params):Boolean {
        var isDown:Boolean;
        for each(var i:Object in params) {
            var ki:KyoKeyVO = _keys[i] as KyoKeyVO;
            isDown          = ki.isDown;
            if (!isDown) {
                return false;
            }
        }
        return isDown;
    }

    /**
     * 按 keyCode 判断是否全部按下。
     * @param params 一个或多个 keyCode。
     * @return 全部按下为 <code>true</code>。
     * @example
     * <listing version="3.0">
     * if (input.isDownCode(65)) { }
     * </listing>
     */
    public function isDownCode(...params):Boolean {
        var isDown:Boolean;
        for each(var i:Object in params) {
            isDown = _downCodes[i] != null;
            if (!isDown) {
                return false;
            }
        }
        return isDown;
    }

    /**
     * 按映射键名判断是否“按过”（若按下则清除其 isDown）。
     * @param params 键名。
     * @return 调用时是否处于按下。
     * @example
     * <listing version="3.0">
     * if (input.isPressKey('A')) { }
     * </listing>
     */
    public function isPressKey(...params):Boolean {
        var isDown:Boolean = isDownKey.apply(null, params);
        if (isDown) {
            for each(var i:Object in params) {
                var ki:KyoKeyVO = _keys[i] as KyoKeyVO;
                ki.isDown       = false;
            }
        }
        return isDown;
    }

    /**
     * 按 keyCode 判断是否“按过”（若按下则从按下表删除）。
     * @param params keyCode。
     * @return 调用时是否处于按下。
     * @example
     * <listing version="3.0">
     * if (input.isPressCode(65)) { }
     * </listing>
     */
    public function isPressCode(...params):Boolean {
        var isDown:Boolean = isDownCode.apply(null, params);
        if (isDown) {
            for each(var i:Object in params) {
                delete _downCodes[i];
            }
        }
        return isDown;
    }

    /**
     * 设置按下 / 抬起回调（参数为映射键名，未映射时为 keyCode）。
     * @param down 按下时调用。
     * @param up 松开时调用；可省略。
     * @example
     * <listing version="3.0">
     * input.addKeyBack(onDown, onUp);
     * </listing>
     */
    public function addKeyBack(down:Function, up:Function = null):void {
        _downF = down;
        _upF   = up;
    }

    /**
     * 判断最近按键顺序是否匹配（匹配成功后清空队列）。
     * @param params 期望顺序的 <code>KyoKeyVO</code> 列表。
     * @return 是否匹配。
     * @example
     * <listing version="3.0">
     * if (input.inorder(KyoKeyCode.A, KyoKeyCode.S, KyoKeyCode.D)) { }
     * </listing>
     * @see #clearInorder()
     */
    public function inorder(...params):Boolean {
        var s:int = _orderKeys.length - params.length;
        if (s < 0) {
            return false;
        }
        var l:int = Math.max(_orderKeys.length, params.length);
        for (var i:int = 0; i < l; i++) {
            var ok:KyoKeyVO = _orderKeys[s + i];
            var pk:KyoKeyVO = params[i];
            if (pk != ok) {
                return false;
            }
        }
        _orderKeys = [];
        return true;
    }

    /**
     * 清空连招顺序队列。
     * @example
     * <listing version="3.0">
     * input.clearInorder();
     * </listing>
     */
    public function clearInorder():void {
        _orderKeys = [];
    }

    /**
     * 清空按 keyCode 记录的按下表。
     * @example
     * <listing version="3.0">
     * input.clearDown();
     * </listing>
     */
    public function clearDown():void {
        _downCodes = {};
    }

    /**
     * @private 重建 code→VO 映射并开启侦听。
     */
    private function updateMapping():void {
        _map = {};
        for each(var i:KyoKeyVO in _keys) {
            _map[i.code] = i;
        }
        turnOn();
    }

    /**
     * @private 写入连招队列。
     */
    private function pushOrder(k:KyoKeyVO):void {
        if (!orderKeyAble) {
            return;
        }
        if (getTimer() - _lastDownTime > orderKeyDuration) {
            _orderKeys = [];
        }
        _lastDownTime = getTimer();
        _orderKeys.push(k);
        if (_orderKeys.length > maxOrderKeyLength) {
            _orderKeys.shift();
        }
    }

    /**
     * @private
     */
    private function keyHandler(e:KeyboardEvent):void {
        var ki:KyoKeyVO;

        if (_map) {
            ki = _map[e.keyCode] as KyoKeyVO;
        }

        if (e.type == KeyboardEvent.KEY_DOWN) {
            if (ki) {
                if (!ki.isDown) {
                    pushOrder(ki);
                }
                ki.isDown = true;
                if (_downF != null) {
                    _downF(ki.name);
                }
            }
            else {
                if (_downF != null) {
                    _downF(e.keyCode);
                }
            }
            _downCodes[e.keyCode] = 1;
        }
        else {
            if (ki) {
                ki.isDown = false;
                if (_upF != null) {
                    _upF(ki.name);
                }
            }
            else {
                if (_upF != null) {
                    _upF(e.keyCode);
                }
            }
            delete _downCodes[e.keyCode];
        }
    }

}
}
