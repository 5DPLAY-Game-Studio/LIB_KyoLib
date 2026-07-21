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
 */
public dynamic class JSEnv extends Proxy {
    /**
     * 指向浏览器 <code>window</code> 的代理实例。
     */
    public static var $:JSEnv = new JSEnv(0);

    /** @private 注册 Notify 回调 */
    private static var _init:* =
            ExternalInterface.addCallback('Notify', handleNotify);

    /** @private AS 函数引用表 */
    private static var FN:Array = [];

    /**
     * @private JS 回调进入 AS。
     */
    private static function handleNotify(id:uint, This:String, ...args):void {
        var AS_Args:Array = [];
        var arg:*;

        for each(arg in args) {
            AS_Args.push(toAS(arg));
        }

        FN[id].apply(toAS(This), AS_Args);
    }

    /**
     * @private 将参数转为 JS 侧标记后追加到 base。
     */
    private static function InsertArg(base:Array, args:Array):Array {
        var arg:*;
        for each(arg in args) {
            base.push(toJS(arg));
        }

        return base;
    }

    /**
     * @private 生成 JS 函数 / 构造代理。
     */
    private static function JS_Proxy(id:int):Function {
        return function (...args):* {
            var arr:Array;
            var ret:*;

            if (this == '[object global]') {
                arr = ['js_call', id];
            }
            else {
                arr = ['js_new', id];
            }

            arr = InsertArg(arr, args);

            ret = ExternalInterface.call.apply(null, arr);
            return toAS(ret);
        };
    }

    /**
     * @private 将 JS 标记还原为 AS 值。
     */
    private static function toAS(val:*):* {
        if (val is String) {
            switch (val.substr(0, 4)) {
            case '_OBJ':
                return new JSEnv(+val.substr(4));

            case '_FUN':
                return JS_Proxy(+val.substr(4)) as Function;
            }
        }

        return val;
    }

    /**
     * @private 将 AS 值编码为传给 JS 的标记。
     */
    private static function toJS(val:*):* {
        if (val is JSEnv) {
            return '_OBJ' + val.obj_id;
        }

        if (val is Function) {
            FN.push(val);
            return '_FUN' + (FN.length - 1);
        }

        return val;
    }

    /**
     * @param id JS 侧引用表 id；0 为 window。
     */
    public function JSEnv(id:int) {
        obj_id = id;
    }

    /** @private */
    private var obj_id:int;

    /**
     * @inheritDoc
     */
    override flash_proxy function hasProperty(name:*):Boolean {
        return ExternalInterface.call('js_in', obj_id, name + '');
    }

    /**
     * @inheritDoc
     */
    override flash_proxy function callProperty(name:*, ...args):* {
        var arr:Array = ['js_method', obj_id, name + ''];
        arr           = InsertArg(arr, args);

        var ret:* = ExternalInterface.call.apply(null, arr);
        return toAS(ret);
    }

    /**
     * @inheritDoc
     */
    override flash_proxy function getProperty(name:*):* {
        var ret:* = ExternalInterface.call('js_get', obj_id, name + '');
        return toAS(ret);
    }

    /**
     * @inheritDoc
     */
    override flash_proxy function setProperty(name:*, value:*):void {
        ExternalInterface.call('js_set', obj_id, name + '', toJS(value));
    }
}
}
