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
import flash.events.TimerEvent;
import flash.external.ExternalInterface;
import flash.net.URLRequest;
import flash.net.navigateToURL;
import flash.text.TextField;
import flash.utils.Timer;
import flash.utils.clearInterval;
import flash.utils.setInterval;

/**
 * 浏览器 / 页面相关工具：打开链接、JS 回调、参数轮询与路径处理。
 *
 * @see #getURL()
 * @see #getParameters()
 * @see #addJSCallback()
 */
public class WebUtils {
    /** @private 缓存的页面 host */
    private static var _url:String;

    /**
     * 在浏览器中打开 URL。
     * @param url 地址；空则仅 trace。
     * @param target 窗口目标。
     * @example
     * <listing version="3.0">
     * WebUtils.getURL('http://example.com');
     * </listing>
     */
    public static function getURL(url:String, target:String = '_blank'):void {
        if (!url) {
            trace('getURL: url is null');
            return;
        }
        try {
            navigateToURL(new URLRequest(url), target);
        }
        catch (e:Error) {
            trace(e);
        }
    }

    /**
     * 向 JS 注册 Flash 回调；可先轮询 <code>jsReady</code> 再注册。
     * @param functionName JS 可调用的函数名。
     * @param closure AS 回调。
     * @param jsReady 返回 Boolean 的 JS 就绪函数名；可省略。
     * @param debugTxt 可选调试文本。
     * @example
     * <listing version="3.0">
     * WebUtils.addJSCallback('flashReady', onCall);
     * </listing>
     */
    public static function addJSCallback(
            functionName:String, closure:Function, jsReady:String = null, debugTxt:TextField = null
    ):void {
        if (jsReady == null) {
            try {
                ExternalInterface.addCallback(functionName, closure);
            }
            catch (e:Error) {
                trace(e);
            }
            return;
        }

        var timer:Timer = new Timer(100);
        timer.addEventListener(TimerEvent.TIMER, function (e:TimerEvent):void {
            var jsVar:Boolean;
            try {
                jsVar = ExternalInterface.call(jsReady);
            }
            catch (err:Error) {
                trace(err);
                timer.stop();
                timer = null;
                return;
            }
            if (debugTxt != null) {
                debugTxt.text = jsVar.toString();
            }
            if (jsVar) {
                addJSCallback(functionName, closure);
                timer.stop();
                timer = null;
            }
        });
        timer.start();
    }

    /**
     * 检查当前页面 URL 是否包含给定锁定域名片段。
     * @param params 字符串或字符串数组（可多个参数）。
     * @return 全部匹配为 <code>true</code>。
     * @example
     * <listing version="3.0">
     * if (WebUtils.checkLockedURL('example.com')) { }
     * </listing>
     */
    public static function checkLockedURL(...params):Boolean {
        for each (var i:Object in params) {
            if (i is Array) {
                for each (var j:String in i) {
                    if (!checkURL(j)) {
                        return false;
                    }
                }
            }
            else if (!checkURL(i as String)) {
                return false;
            }
        }

        return true;
    }

    /**
     * 轮询获取 SWF URL 参数。
     * @param stage 舞台。
     * @param checkVar 用于检测是否就绪的参数键。
     * @param back 成功回调，参数为 parameters 对象。
     * @param timeout 超时毫秒；0 表示一直等到取到。
     * @example
     * <listing version="3.0">
     * WebUtils.getParameters(stage, 'id', onParams, 5000);
     * </listing>
     */
    public static function getParameters(stage:Stage, checkVar:String, back:Function, timeout:int = 0):void {
        var loadInt:int   = setInterval(loadp, 300);
        var loadTimes:int = timeout == 0 ? -1 : Math.ceil(timeout / 300);

        function loadp():void {
            var ckVar:Object = stage.loaderInfo.parameters[checkVar];
            if (loadTimes > 0) {
                loadTimes--;
            }
            if (ckVar || loadTimes == 0) {
                clearInterval(loadInt);
                if (back != null) {
                    back(stage.loaderInfo.parameters);
                }
            }
        }
    }

    /**
     * 取当前 SWF 所在目录 URL。
     * @param s 舞台。
     * @return 目录路径（含末尾 <code>/</code>）。
     * @example
     * <listing version="3.0">
     * var base:String = WebUtils.getLocalUrl(stage);
     * </listing>
     */
    public static function getLocalUrl(s:Stage):String {
        var url:String = s.loaderInfo.url;
        var i:int      = url.lastIndexOf('/');

        return url.substr(0, i + 1);
    }

    /**
     * 在匹配键后插入路径，并修正重复的 <code>http://</code>。
     * @param txt 原文。
     * @param matchKey 匹配键。
     * @param urlPath 插入路径。
     * @return 替换后字符串。
     * @example
     * <listing version="3.0">
     * WebUtils.replaceUrl(html, 'src=', base);
     * </listing>
     */
    public static function replaceUrl(txt:String, matchKey:String, urlPath:String):String {
        var v:String = txt.replace(matchKey, matchKey + urlPath);
        v            = v.replace(urlPath + 'http://', 'http://');

        return v;
    }

    /**
     * 取 URL 目录部分（按 <code>/</code>）。
     * @param url 完整 URL。
     * @return 目录。
     * @example
     * <listing version="3.0">
     * WebUtils.getUrlFolder(url);
     * </listing>
     */
    public static function getUrlFolder(url:String):String {
        var x:int = url.lastIndexOf('/');

        return url.substr(0, x + 1);
    }

    /**
     * 取本地路径目录部分（按 <code>\\</code>）。
     * @param url 本地路径。
     * @return 目录。
     * @example
     * <listing version="3.0">
     * WebUtils.getLocalFolder(path);
     * </listing>
     */
    public static function getLocalFolder(url:String):String {
        var x:int = url.lastIndexOf('\\');

        return url.substr(0, x + 1);
    }

    /**
     * 取当前 SWF 文件名。
     * @param stage 舞台。
     * @return 文件名。
     * @example
     * <listing version="3.0">
     * WebUtils.getFileName(stage);
     * </listing>
     */
    public static function getFileName(stage:Stage):String {
        var url:String = stage.loaderInfo.url;
        var x:int      = url.lastIndexOf('/');

        return url.substr(x + 1);
    }

    /**
     * 取当前 SWF 所在目录。
     * @param stage 舞台。
     * @return 目录 URL。
     * @example
     * <listing version="3.0">
     * WebUtils.getStageUrlFolder(stage);
     * </listing>
     */
    public static function getStageUrlFolder(stage:Stage):String {
        return getUrlFolder(stage.loaderInfo.url);
    }

    /**
     * 刷新页面。
     * @example
     * <listing version="3.0">
     * WebUtils.refresh();
     * </listing>
     */
    public static function refresh():void {
        getURL('javascript:location.reload();', '_self');
    }

    /**
     * 调用 JS <code>alert</code>。
     * @param v 提示文本。
     * @example
     * <listing version="3.0">
     * WebUtils.alert('ok');
     * </listing>
     */
    public static function alert(v:String):void {
        getURL('javascript:alert("' + v + '");', '_self');
    }

    /** @private */
    private static function checkURL(url:String):Boolean {
        if (_url == null) {
            try {
                _url = ExternalInterface.call('eval', 'window.location.href');
            }
            catch (e:Error) {
                trace(e);
                return false;
            }
            var s:int        = _url.indexOf('//') + 2;
            var endIndex:int = _url.indexOf('/', s);
            endIndex         = endIndex == -1 ? int.MAX_VALUE : endIndex - s;
            _url             = _url.substr(s, endIndex);
        }

        return _url.indexOf(url) != -1;
    }

}
}

