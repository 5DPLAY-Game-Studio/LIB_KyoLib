/*
 * Copyright (C) 2021-2025, 5DPLAY Game Studio
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
 * 颜色常量与简单运算工具。
 *
 * <p>常量为 24 位 RGB（<code>0xRRGGBB</code>）。</p>
 *
 * @example
 * <listing version="3.0">
 * var c:uint = KyoColor.rgb(255, 128, 0);
 * var hex:String = KyoColor.toHex(KyoColor.ORANGE);
 * </listing>
 * @see #rgb()
 * @see #toHex()
 * @see net.play5d.kyo.utils.KyoRandom#getRandomColor()
 */
public class KyoColor {

    // ----- 基础 -----

    /** 黑 <code>0x000000</code> */
    public static const BLACK:uint = 0x000000;
    /** 白 <code>0xFFFFFF</code> */
    public static const WHITE:uint = 0xFFFFFF;

    /** 红 <code>0xFF0000</code> */
    public static const RED:uint = 0xFF0000;
    /** 绿 <code>0x00FF00</code> */
    public static const GREEN:uint = 0x00FF00;
    /** 蓝 <code>0x0000FF</code> */
    public static const BLUE:uint = 0x0000FF;

    /** 黄 <code>0xFFFF00</code>（红|绿） */
    public static const YELLOW:uint = RED | GREEN;
    /**
     * 品红 <code>0xFF00FF</code>（红|蓝）。
     * <p>历史别名，等同 <code>MAGENTA</code>。</p>
     */
    public static const PINK:uint = RED | BLUE;
    /** 青 <code>0x00FFFF</code>（绿|蓝） */
    public static const CYAN:uint = GREEN | BLUE;

    // ----- 扩展原色 / 别名 -----

    /** 品红 <code>0xFF00FF</code> */
    public static const MAGENTA:uint = PINK;
    /** 青绿别名，等同 <code>CYAN</code> */
    public static const AQUA:uint = CYAN;
    /** 亮绿别名，等同 <code>GREEN</code> */
    public static const LIME:uint = GREEN;
    /** 紫红别名，等同 <code>MAGENTA</code> */
    public static const FUCHSIA:uint = MAGENTA;

    // ----- 灰阶 -----

    /** 深灰 <code>0x404040</code> */
    public static const DARK_GRAY:uint = 0x404040;
    /** 灰 <code>0x808080</code> */
    public static const GRAY:uint = 0x808080;
    /** 银 <code>0xC0C0C0</code> */
    public static const SILVER:uint = 0xC0C0C0;
    /** 浅灰 <code>0xD3D3D3</code> */
    public static const LIGHT_GRAY:uint = 0xD3D3D3;

    // ----- 常用命名色 -----

    /** 橙 <code>0xFFA500</code> */
    public static const ORANGE:uint = 0xFFA500;
    /** 金 <code>0xFFD700</code> */
    public static const GOLD:uint = 0xFFD700;
    /** 珊瑚 <code>0xFF7F50</code> */
    public static const CORAL:uint = 0xFF7F50;
    /** 褐 <code>0xA52A2A</code> */
    public static const BROWN:uint = 0xA52A2A;
    /** 栗色 <code>0x800000</code> */
    public static const MAROON:uint = 0x800000;
    /** 橄榄 <code>0x808000</code> */
    public static const OLIVE:uint = 0x808000;
    /** 海军蓝 <code>0x000080</code> */
    public static const NAVY:uint = 0x000080;
    /** 青绿 <code>0x008080</code> */
    public static const TEAL:uint = 0x008080;
    /** 紫 <code>0x800080</code> */
    public static const PURPLE:uint = 0x800080;
    /** 靛 <code>0x4B0082</code> */
    public static const INDIGO:uint = 0x4B0082;
    /** 紫罗兰 <code>0xEE82EE</code> */
    public static const VIOLET:uint = 0xEE82EE;
    /** 粉红 <code>0xFFC0CB</code>（浅粉，区别于 <code>PINK</code> 品红） */
    public static const LIGHT_PINK:uint = 0xFFC0CB;
    /** 天空蓝 <code>0x87CEEB</code> */
    public static const SKY_BLUE:uint = 0x87CEEB;
    /** 深蓝 <code>0x00008B</code> */
    public static const DARK_BLUE:uint = 0x00008B;
    /** 深绿 <code>0x006400</code> */
    public static const DARK_GREEN:uint = 0x006400;
    /** 深红 <code>0x8B0000</code> */
    public static const DARK_RED:uint = 0x8B0000;
    /** 卡其 <code>0xF0E68C</code> */
    public static const KHAKI:uint = 0xF0E68C;
    /** 米色 <code>0xF5F5DC</code> */
    public static const BEIGE:uint = 0xF5F5DC;
    /** 象牙 <code>0xFFFFF0</code> */
    public static const IVORY:uint = 0xFFFFF0;
    /** 番茄红 <code>0xFF6347</code> */
    public static const TOMATO:uint = 0xFF6347;
    /** 巧克力 <code>0xD2691E</code> */
    public static const CHOCOLATE:uint = 0xD2691E;
    /** 深蓝灰 <code>0x2F4F4F</code> */
    public static const DARK_SLATE_GRAY:uint = 0x2F4F4F;

    /**
     * 由 RGB 分量合成颜色。
     * @param r 红 0–255。
     * @param g 绿 0–255。
     * @param b 蓝 0–255。
     * @return <code>0xRRGGBB</code>。
     * @example
     * <listing version="3.0">
     * KyoColor.rgb(255, 128, 0); // 0xFF8000
     * </listing>
     */
    public static function rgb(r:uint, g:uint, b:uint):uint {
        return ((r & 0xFF) << 16) | ((g & 0xFF) << 8) | (b & 0xFF);
    }

    /**
     * 取红色分量。
     * @param color <code>0xRRGGBB</code>。
     * @return 0–255。
     * @example
     * <listing version="3.0">
     * KyoColor.getR(0xFF8000); // 255
     * </listing>
     */
    public static function getR(color:uint):uint {
        return (color >> 16) & 0xFF;
    }

    /**
     * 取绿色分量。
     * @param color <code>0xRRGGBB</code>。
     * @return 0–255。
     * @example
     * <listing version="3.0">
     * KyoColor.getG(0xFF8000); // 128
     * </listing>
     */
    public static function getG(color:uint):uint {
        return (color >> 8) & 0xFF;
    }

    /**
     * 取蓝色分量。
     * @param color <code>0xRRGGBB</code>。
     * @return 0–255。
     * @example
     * <listing version="3.0">
     * KyoColor.getB(0xFF8000); // 0
     * </listing>
     */
    public static function getB(color:uint):uint {
        return color & 0xFF;
    }

    /**
     * 线性插值两色。
     * @param from 起始色。
     * @param to 目标色。
     * @param ratio 比例，建议 <code>[0, 1]</code>。
     * @return 插值结果。
     * @example
     * <listing version="3.0">
     * KyoColor.lerp(KyoColor.BLACK, KyoColor.WHITE, 0.5);
     * </listing>
     */
    public static function lerp(from:uint, to:uint, ratio:Number):uint {
        if (ratio <= 0) {
            return from;
        }
        if (ratio >= 1) {
            return to;
        }
        var r:int = getR(from) + (int(getR(to)) - int(getR(from))) * ratio;
        var g:int = getG(from) + (int(getG(to)) - int(getG(from))) * ratio;
        var b:int = getB(from) + (int(getB(to)) - int(getB(from))) * ratio;
        return rgb(r, g, b);
    }

    /**
     * 转为 <code>#RRGGBB</code> 字符串。
     * @param color 颜色值。
     * @return 大写十六进制，含 <code>#</code>。
     * @example
     * <listing version="3.0">
     * KyoColor.toHex(KyoColor.RED); // '#FF0000'
     * </listing>
     */
    public static function toHex(color:uint):String {
        var hex:String = (color & 0xFFFFFF).toString(16).toUpperCase();
        while (hex.length < 6) {
            hex = '0' + hex;
        }
        return '#' + hex;
    }

}
}
