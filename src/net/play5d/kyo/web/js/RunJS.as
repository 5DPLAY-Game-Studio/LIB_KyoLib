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
    function RunJS() {
        JSLine('DOM Demo:');
        JSDemo1();

        JSLine('Event Demo:');
        JSDemo2();

        JSLine('Closure Demo:');
        JSDemo3();

        JSLine('AJAX Demo:');
        JSDemo4();
    }

    /**
     * 浏览器 window 代理。
     */
    private var window:JSEnv = JSEnv.$;

    /**
     * 在页面插入分隔标题。
     * @param str 标题文本。
     */
    internal function JSLine(str:*):void {
        var doc:* = window.document;
        var div:* = doc.createElement('div');

        div.innerHTML = '<p>' + str + '<hr/></p>';
        doc.body.appendChild(div);
    }

    /**
     * DOM 创建样式盒子演示。
     */
    internal function JSDemo1():void {
        var doc:* = window.document;
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
    internal function JSDemo2():void {
        var doc:* = window.document;
        var btn:* = doc.createElement('button');

        btn.innerHTML = 'Click Me!';
        btn.onclick   = function ():void {
            var i:int = 0;
            window.setInterval(function ():void {
                btn.innerHTML = 'Run in ActionScript: i=' + i++;
            }, 10);
        };

        doc.body.appendChild(btn);
    }

    /**
     * 闭包绑定循环索引演示。
     */
    internal function JSDemo3():void {
        var doc:* = window.document;

        for (var i:int = 0; i < 5; i++) {
            var btn:* = doc.createElement('button');
            doc.body.appendChild(btn);

            btn.innerHTML = 'Button' + i;
            btn.onclick   = (
                    function (i:*):* {
                        return function ():void {
                            window.alert(i);
                        };
                    }
            )(i);
        }
    }

    /**
     * XMLHttpRequest / ActiveX 加载演示。
     */
    internal function JSDemo4():void {
        var doc:* = window.document;
        var btn:* = doc.createElement('button');

        doc.body.appendChild(btn);

        btn.innerHTML = 'Load Test.xml';

        btn.onclick = function ():void {
            var xhr:* = window.ActiveXObject ?
                        new window.ActiveXObject('Microsoft.XMLHTTP') :
                        new window.XMLHttpRequest;

            xhr.onreadystatechange = function ():void {
                if (xhr.readyState != 4) {
                    return;
                }

                window.alert(xhr.responseText);
            };

            xhr.open('GET', 'Test.xml', true);
            xhr.send();
        };
    }
}
}
