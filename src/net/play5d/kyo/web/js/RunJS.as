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
import flash.display.Sprite;

/**
 * <code>JSEnv</code> 演示：DOM、事件、闭包与 AJAX。
 *
 * @see JSEnv
 */
public class RunJS extends Sprite {
    /**
     * 构造后依次运行各演示。
     */
    public function RunJS() {
        jsLine('DOM Demo:');
        demoDom();

        jsLine('Event Demo:');
        demoEvent();

        jsLine('Closure Demo:');
        demoClosure();

        jsLine('AJAX Demo:');
        demoAjax();
    }

    /**
     * 浏览器 window 代理。
     */
    private var _window:JSEnv = JSEnv.$;

    /**
     * 在页面插入分隔标题。
     * @param str 标题文本。
     */
    internal function jsLine(str:*):void {
        var doc:* = _window.document;
        var div:* = doc.createElement('div');

        div.innerHTML = '<p>' + str + '<hr/></p>';
        doc.body.appendChild(div);
    }

    /**
     * DOM 创建样式盒子演示。
     */
    internal function demoDom():void {
        var doc:* = _window.document;
        var div:* = doc.createElement('div');

        div.innerHTML = 'Hello! <i>This box is created by ActionScript!</i>';

        div.style.background = '#CCC';
        div.style.font       = 'bolder 18px \'Courier New\'';
        div.style.border     = '1px dashed #693';

        doc.body.appendChild(div);
    }

    /**
     * 按钮点击与 setInterval 演示。
     */
    internal function demoEvent():void {
        var doc:* = _window.document;
        var btn:* = doc.createElement('button');

        btn.innerHTML = 'Click Me!';
        btn.onclick   = function ():void {
            var i:int = 0;
            _window.setInterval(function ():void {
                btn.innerHTML = 'Run in ActionScript: i=' + i++;
            }, 10);
        };

        doc.body.appendChild(btn);
    }

    /**
     * 闭包绑定循环索引演示。
     */
    internal function demoClosure():void {
        var doc:* = _window.document;

        for (var i:int = 0; i < 5; i++) {
            var btn:* = doc.createElement('button');
            doc.body.appendChild(btn);

            btn.innerHTML = 'Button' + i;
            btn.onclick   = (function (idx:*):* {
                return function ():void {
                    _window.alert(idx);
                };
            })(i);
        }
    }

    /**
     * XMLHttpRequest / ActiveX 加载演示。
     */
    internal function demoAjax():void {
        var doc:* = _window.document;
        var btn:* = doc.createElement('button');

        doc.body.appendChild(btn);

        btn.innerHTML = 'Load Test.xml';

        btn.onclick = function ():void {
            // [] 取构造函数再 new：as3mxml 会把 new _window.XMLHttpRequest 当成类型名
            var xhr:*;
            var axCtor:* = _window['ActiveXObject'];
            if (axCtor) {
                xhr = new axCtor('Microsoft.XMLHTTP');
            }
            else {
                var xhrCtor:* = _window['XMLHttpRequest'];
                xhr = new xhrCtor();
            }

            xhr.onreadystatechange = function ():void {
                if (xhr.readyState != 4) {
                    return;
                }
                _window.alert(xhr.responseText);
            };

            xhr.open('GET', 'Test.xml', true);
            xhr.send();
        };
    }
}
}

