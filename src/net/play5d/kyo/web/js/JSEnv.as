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

package net.play5d.kyo.web.js {
import flash.external.ExternalInterface;
import flash.utils.Proxy;
import flash.utils.flash_proxy;

/**
 * 通过 <code>ExternalInterface</code> 代理浏览器 JS 对象（配合页面 <code>AS.js</code>）。
 *
 * <p>静态 <code>$</code> 对应 <code>window</code>（引用 id 0）。</p>
 *
 * @see #$
 * @see RunJS
 * @example
 * <listing version="3.0">
 * var doc:* = JSEnv.$.document;
 * doc.body.appendChild(doc.createElement('div'));
 * </listing>
 */
public dynamic class JSEnv extends Proxy {
    /**
     * 指向浏览器 <code>window</code> 的代理实例。
     */
    public static var $:JSEnv = new JSEnv(0);

    /** @private 注册 Notify 回调（副作用初始化） */
    private static var _notifyInited:* = ExternalInterface.addCallback('Notify', handleNotify);

    /** @private AS 函数引用表 */
    private static var _fn:Array = [];

    /**
     * 构造 JS 对象代理。
     * @param id JS 侧引用表 id；0 为 window。
     */
    public function JSEnv(id:int) {
        _objId = id;
    }

    /** @private */
    private var _objId:int;

    /** @private JS 回调进入 AS。 */
    private static function handleNotify(id:uint, thisRef:String, ...args):void {
        var asArgs:Array = [];
        for each (var arg:* in args) {
            asArgs.push(toAS(arg));
        }
        _fn[id].apply(toAS(thisRef), asArgs);
    }

    /** @private 将参数转为 JS 侧标记后追加到 base。 */
    private static function insertArg(base:Array, args:Array):Array {
        for each (var arg:* in args) {
            base.push(toJS(arg));
        }

        return base;
    }

    /** @private 生成 JS 函数 / 构造代理。 */
    private static function jsProxy(id:int):Function {
        // 必须用调用现场 this（非外层 JSEnv）：fn() → global → js_call；new fn() → 实例 → js_new
        // as3mxml 20000 会提示闭包 this，此处为有意行为，勿改成绑定方法
        return function (...args):* {
            var arr:Array;
            if (this == '[object global]') {
                arr = ['js_call', id];
            }
            else {
                arr = ['js_new', id];
            }
            arr = insertArg(arr, args);

            return toAS(ExternalInterface.call.apply(null, arr));
        };
    }

    /** @private 将 JS 标记还原为 AS 值。 */
    private static function toAS(val:*):* {
        if (val is String) {
            switch (val.substr(0, 4)) {
            case '_OBJ':
                return new JSEnv(+val.substr(4));
            case '_FUN':
                return jsProxy(+val.substr(4)) as Function;
            }
        }

        return val;
    }

    /** @private 将 AS 值编码为传给 JS 的标记。 */
    private static function toJS(val:*):* {
        if (val is JSEnv) {
            return '_OBJ' + val._objId;
        }
        if (val is Function) {
            _fn.push(val);

            return '_FUN' + (_fn.length - 1);
        }

        return val;
    }

    /**
     * @inheritDoc
     */
    override flash_proxy function hasProperty(name:*):Boolean {
        return ExternalInterface.call('js_in', _objId, name + '');
    }

    /**
     * @inheritDoc
     */
    override flash_proxy function callProperty(name:*, ...args):* {
        var arr:Array = ['js_method', _objId, name + ''];
        arr           = insertArg(arr, args);

        return toAS(ExternalInterface.call.apply(null, arr));
    }

    /**
     * @inheritDoc
     */
    override flash_proxy function getProperty(name:*):* {
        return toAS(ExternalInterface.call('js_get', _objId, name + ''));
    }

    /**
     * @inheritDoc
     */
    override flash_proxy function setProperty(name:*, value:*):void {
        ExternalInterface.call('js_set', _objId, name + '', toJS(value));
    }
}
}

