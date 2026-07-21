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
import flash.events.IOErrorEvent;
import flash.events.SecurityErrorEvent;
import flash.net.URLLoader;
import flash.net.URLRequest;

import net.play5d.kyo.utils.vo.KyoWeaterVO;

/**
 * 从 Yahoo Weather RSS 加载天气，并解析今日 / 明日预报。
 *
 * @see #loadWeather()
 * @see #todayWeather
 * @see net.play5d.kyo.utils.vo.KyoWeaterVO
 */
public class KyoWeather {
    /** @private */
    private static var _weatherxml:XML;
    /** @private */
    private static var yweather:Namespace = new Namespace('http://xml.weather.yahoo.com/ns/rss/1.0');

    /** @private */
    private static var _todayWeather:KyoWeaterVO;

    /**
     * 今日天气；未加载成功则为 <code>null</code>。
     */
    public static function get todayWeather():KyoWeaterVO {
        if (!_weatherxml) {
            return null;
        }
        if (!_todayWeather) {
            _todayWeather      = new KyoWeaterVO();
            var x:XML          = _weatherxml.channel.item.yweather::forecast[0];
            _todayWeather.low  = x.@low;
            _todayWeather.high = x.@high;
            _todayWeather.code = x.@code;
        }
        return _todayWeather;
    }

    /** @private */
    private static var _tomorrowWeather:KyoWeaterVO;

    /**
     * 明日天气；未加载成功则为 <code>null</code>。
     */
    public static function get tomorrowWeather():KyoWeaterVO {
        if (!_weatherxml) {
            return null;
        }
        if (!_tomorrowWeather) {
            _tomorrowWeather      = new KyoWeaterVO();
            var x:XML             = _weatherxml.channel.item.yweather::forecast[1];
            _tomorrowWeather.low  = x.@low;
            _tomorrowWeather.high = x.@high;
            _tomorrowWeather.code = x.@code;
        }
        return _tomorrowWeather;
    }

    /**
     * 按城市 WOEID 加载摄氏度预报 RSS。
     * @param cityCode Yahoo 城市代码。
     * @param back 成功回调，无参数；可省略。
     * @param error 失败回调，无参数；可省略。
     * @example
     * <listing version="3.0">
     * KyoWeather.loadWeather(2151330, onOk);
     * </listing>
     */
    public static function loadWeather(cityCode:int, back:Function = null, error:Function = null):void {
        var url:String   = 'http://weather.yahooapis.com/forecastrss' +
                           '?w=' + cityCode + '&u=c';
        var ul:URLLoader = new URLLoader(new URLRequest(url));
        ul.addEventListener(Event.COMPLETE, success);
        ul.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
        ul.addEventListener(SecurityErrorEvent.SECURITY_ERROR, errorHandler);

        function success(e:Event):void {
            removeListeners();
            _weatherxml = new XML(ul.data);
            if (back != null) {
                back();
            }
            ul = null;
        }

        function errorHandler(e:Event):void {
            removeListeners();
            if (error != null) {
                error();
            }
            ul = null;
        }

        function removeListeners():void {
            ul.removeEventListener(Event.COMPLETE, success);
            ul.removeEventListener(IOErrorEvent.IO_ERROR, errorHandler);
            ul.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, errorHandler);
        }
    }

}
}
