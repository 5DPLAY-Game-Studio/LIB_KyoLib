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

package net.play5d.kyo.utils.vo {
/**
 * 天气数据值对象：最高 / 最低温与天气代码。
 *
 * @see net.play5d.kyo.utils.KyoWeather
 */
public class KyoWeatherVO {
    /**
     * 最高温度。
     * @default 0
     */
    public var high:int;
    /**
     * 最低温度。
     * @default 0
     */
    public var low:int;
    /**
     * 天气代码。
     * @default 0
     */
    public var code:int;
}
}
