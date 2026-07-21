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

/**
 * Flash ↔ JS 桥接页脚脚本：对象/函数引用表与 js_* 入口供 ExternalInterface 调用。
 * 需与页面中 id 为 `fla` 的 Flash 对象及 AS 侧 `JSEnv` 配合。
 */
+function () {
    var arrRef = [window];
    var numRef = 0;

    var isIE = !window.addEventListener;
    var fla;

    /**
     * 将值存入引用表并返回 id。
     * @param {*} val JS 对象或函数。
     * @returns {number} 引用 id。
     */
    function RefPut(val) {
        arrRef[++numRef] = val;
        return numRef;
    }

    /**
     * 把参数转为 AS 可识别形式后调用 Flash `Notify`。
     * @param {number} id 回调 id。
     * @returns {*} Flash 返回值。
     */
    function AS_Dispatch(id) {
        var args = [id];

        for (var i = 1, n = arguments.length; i < n; i++) {
            args[i] = toAS(arguments[i]);
        }

        return fla.Notify.apply(fla, args);
    }

    /**
     * 生成调用 AS 侧函数的代理。
     * @param {number} id 函数引用 id。
     * @returns {Function}
     */
    function AS_Proxy(id) {
        return function () {
            return AS_Dispatch(id, this, arguments);
        };
    }

    /**
     * 将 JS 值编码为传给 AS 的标记或原值。
     * @param {*} val
     * @returns {*}
     */
    function toAS(val) {
        switch (typeof val) {
            case 'object':
                return '_OBJ' + RefPut(val);

            case 'function':
                return '_FUN' + RefPut(val);
        }

        return val;
    }

    /**
     * 将 AS 传来的标记还原为 JS 对象/函数代理。
     * @param {*} val
     * @returns {*}
     */
    function toJS(val) {
        if (typeof val == 'string') {
            switch (val.substr(0, 4)) {
                case '_OBJ':
                    return arrRef[+val.substr(4)];
                case '_FUN':
                    if (!fla) {
                        fla = document.getElementById('fla');
                    }

                    return AS_Proxy(+val.substr(4));
            }
        }

        return val;
    }

    /**
     * 判断引用对象上是否存在属性。
     * @param {number} id
     * @param {string} name
     * @returns {boolean}
     */
    js_in = function (id, name) {
        return name in arrRef[id];
    };

    /**
     * 读取引用对象属性并编码回 AS。
     * @param {number} id
     * @param {string} name
     * @returns {*}
     */
    js_get = function (id, name) {
        var val = arrRef[id][name];

        return toAS(val);
    };

    /**
     * 设置引用对象属性。
     * @param {number} id
     * @param {string} name
     * @param {*} val AS 侧传入值。
     */
    js_set = function (id, name, val) {
        arrRef[id][name] = toJS(val);
    };

    /**
     * 调用引用对象上的方法。
     * @param {number} id
     * @param {string} name
     * @returns {*}
     */
    js_method = function (id, name) {
        var i = 0, n = arguments.length - 2, $ = [];

        for (; i < n; i++) {
            $[i] = toJS(arguments[i + 2]);
        }

        var obj = arrRef[id];

        if (isIE && !(obj instanceof Object)) {
            // IE 宿主对象（alert、XMLHTTP 等）可能不是 Function
            switch (n) {
                case 0:
                    return toAS(obj[name]());
                case 1:
                    return toAS(obj[name]($[0]));
                case 2:
                    return toAS(obj[name]($[0], $[1]));
                case 3:
                    return toAS(obj[name]($[0], $[1], $[2]));
                case 4:
                    return toAS(obj[name]($[0], $[1], $[2], $[3]));
                case 5:
                    return toAS(obj[name]($[0], $[1], $[2], $[3], $[4]));
                default:
                    return;
            }
        }

        var ret = obj[name].apply(obj, $);
        return toAS(ret);
    };

    /**
     * 以函数方式调用引用表中的函数。
     * @param {number} id
     * @returns {*}
     */
    js_call = function (id) {
        var i = 0, n = arguments.length - 1, args = [];

        for (; i < n; i++) {
            args[i] = toJS(arguments[i + 1]);
        }

        var ret = arrRef[id].apply(null, args);
        return toAS(ret);
    };

    /**
     * 以 `new` 方式构造引用表中的构造函数（最多 8 个参数）。
     * @param {number} id
     * @returns {*}
     */
    js_new = function (id) {
        var i = 0, n = arguments.length - 1, $ = [];

        for (; i < n; i++) {
            $[i] = toJS(arguments[i + 1]);
        }

        switch (n) {
            case 0:
                return toAS(new arrRef[id]());
            case 1:
                return toAS(new arrRef[id]($[0]));
            case 2:
                return toAS(new arrRef[id]($[0], $[1]));
            case 3:
                return toAS(new arrRef[id]($[0], $[1], $[2]));
            case 4:
                return toAS(new arrRef[id]($[0], $[1], $[2], $[3]));
            case 5:
                return toAS(new arrRef[id]($[0], $[1], $[2], $[3], $[4]));
            case 6:
                return toAS(new arrRef[id]($[0], $[1], $[2], $[3], $[4], $[5]));
            case 7:
                return toAS(new arrRef[id]($[0], $[1], $[2], $[3], $[4], $[5], $[6]));
            case 8:
                return toAS(new arrRef[id]($[0], $[1], $[2], $[3], $[4], $[5], $[6], $[7]));
        }
    };
}();
