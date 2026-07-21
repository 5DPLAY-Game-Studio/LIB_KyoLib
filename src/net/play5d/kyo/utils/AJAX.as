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

package net.play5d.kyo.utils {
import flash.events.Event;
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.net.URLRequestMethod;
import flash.net.URLVariables;

/**
 * 简易 HTTP GET / POST 封装。
 *
 * @see #get()
 * @see #post()
 */
public class AJAX {
    /**
     * 以 POST 请求 URL。
     * @param url 地址。
     * @param data 表单变量；可省略。
     * @param back 成功回调，参数为响应数据；可省略。
     * @example
     * <listing version="3.0">
     * AJAX.post('api.php', vars, onData);
     * </listing>
     */
    public static function post(url:String, data:URLVariables = null, back:Function = null):void {
        loadurl(url, data, URLRequestMethod.POST, back);
    }

    /**
     * 以 GET 请求 URL。
     * @param url 地址。
     * @param data 查询变量；可省略。
     * @param back 成功回调，参数为响应数据；可省略。
     * @example
     * <listing version="3.0">
     * AJAX.get('api.php', vars, onData);
     * </listing>
     */
    public static function get(url:String, data:URLVariables = null, back:Function = null):void {
        loadurl(url, data, URLRequestMethod.GET, back);
    }

    /**
     * @private
     */
    private static function loadurl(url:String, obj:Object, method:String, back:Function):void {
        var rq:URLRequest = new URLRequest(url);
        rq.data           = obj;
        rq.method         = method;
        var l:URLLoader   = new URLLoader();
        l.addEventListener(Event.COMPLETE, function ():void {
            trace('url访问成功');
            if (back != null) {
                back(l.data);
            }
        });
        l.load(rq);
    }

    /**
     * 构造函数（本类以静态方法使用，通常无需实例化）。
     */
    public function AJAX() {
    }

}
}
