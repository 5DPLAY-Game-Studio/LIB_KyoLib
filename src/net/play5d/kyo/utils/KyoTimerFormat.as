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
/**
 * 时间 / 日期格式化工具。
 *
 * @see #getTime()
 * @see #getDate()
 * @see #secToTime()
 * @see KyoClock
 * @author kyo
 */
public class KyoTimerFormat {
    /** @private 英文星期 */
    private static const EN_DAYS:Object = {
        0: 'Sunday',
        1: 'Monday',
        2: 'Tuesday',
        3: 'Wednesday',
        4: 'Thursday',
        5: 'Friday',
        6: 'Saturday'
    };
    /** @private 中文星期 */
    private static const CN_DAYS:Object = {
        0: '星期天',
        1: '星期一',
        2: '星期二',
        3: '星期三',
        4: '星期四',
        5: '星期五',
        6: '星期六'
    };

    /**
     * 是否为上午。
     * @param date 日期。
     * @return hours &lt; 12。
     * @example
     * <listing version="3.0">
     * KyoTimerFormat.isAM(new Date());
     * </listing>
     */
    public static function isAM(date:Date):Boolean {
        return date.hours < 12;
    }

    /**
     * 格式化时分秒。
     * @param date 日期。
     * @param sign 分隔符。
     * @param second 是否含秒。
     * @param type24 是否 24 小时制。
     * @return 时间字符串。
     * @example
     * <listing version="3.0">
     * KyoTimerFormat.getTime(new Date());
     * </listing>
     */
    public static function getTime(
            date:Date, sign:String = ' : ', second:Boolean = true, type24:Boolean = true
    ):String {
        var h:int    = date.hours;
        var m:String = formatNum(date.minutes);
        var s:String = second ? sign + formatNum(date.seconds) : '';
        if (!type24 && h > 12) {
            h -= 12;
        }

        return formatNum(h) + sign + m + s;
    }

    /**
     * 格式化年月日。
     * @param date 日期。
     * @param sign 分隔符。
     * @return 日期字符串。
     * @example
     * <listing version="3.0">
     * KyoTimerFormat.getDate(new Date());
     * </listing>
     */
    public static function getDate(date:Date, sign:String = '/'):String {
        return date.fullYear + sign + formatNum(date.month + 1) + sign + formatNum(date.date);
    }

    /**
     * 日期 + 时间。
     * @param date 日期。
     * @param signDate 日期分隔符。
     * @param signTime 时间分隔符。
     * @param second 是否含秒。
     * @param type24 是否 24 小时制。
     * @return 组合字符串。
     * @example
     * <listing version="3.0">
     * KyoTimerFormat.getDateTime(new Date());
     * </listing>
     */
    public static function getDateTime(
            date:Date, signDate:String = '/', signTime:String = ' : ', second:Boolean = true, type24:Boolean = true
    ):String {
        return getDate(date, signDate) + ' ' + getTime(date, signTime, second, type24);
    }

    /**
     * 获取星期几。
     * @param date 日期。
     * @param type 0=数字；1=英文；2=中文。
     * @return 星期字符串。
     * @example
     * <listing version="3.0">
     * KyoTimerFormat.getDay(new Date(), 2);
     * </listing>
     */
    public static function getDay(date:Date, type:int = 1):String {
        var n:int = date.day;
        switch (type) {
        case 1:
            return EN_DAYS[n];
        case 2:
            return CN_DAYS[n];
        default:
            return n.toString();
        }
    }

    /**
     * 将秒数转为时:分:秒。
     * @param s 总秒数。
     * @param gap 分隔符。
     * @param second 是否含秒段。
     * @param hour 是否含小时段。
     * @return 时间字符串。
     * @example
     * <listing version="3.0">
     * KyoTimerFormat.secToTime(3661); // 01:01:01
     * </listing>
     */
    public static function secToTime(s:int, gap:String = ':', second:Boolean = true, hour:Boolean = true):String {
        var h:int = s / 60 / 60;
        s -= h * 60 * 60;
        var m:int = s / 60;
        s -= m * 60;

        var hs:String = '';
        if (hour) {
            hs = h >= 10 ? h.toString() : '0' + h;
            hs += gap;
        }

        var ms:String = m >= 10 ? m.toString() : '0' + m;

        var ss:String = '';
        if (second) {
            ss = s >= 10 ? s.toString() : '0' + s;
            ss = gap + ss;
        }

        return hs + ms + ss;
    }

    /**
     * 两位补零（委托 <code>KyoStringUtils.padNumber</code>）。
     * @param n 整数。
     * @return 至少两位的字符串。
     * @example
     * <listing version="3.0">
     * KyoTimerFormat.formatNum(5); // '05'
     * </listing>
     * @see KyoStringUtils#padNumber()
     */
    public static function formatNum(n:int):String {
        return KyoStringUtils.padNumber(n, 2);
    }

}
}

