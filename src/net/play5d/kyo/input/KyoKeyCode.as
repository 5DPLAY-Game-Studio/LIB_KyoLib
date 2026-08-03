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

package net.play5d.kyo.input {
/**
 * 常用键盘键常量表（名称 + keyCode），并提供 code→name 查询。
 *
 * @see KyoKeyVO
 * @see #code2name()
 */
public class KyoKeyCode {
    /** 主键盘 <code>0</code>（keyCode 48）。 */
    public static const N0:KyoKeyVO = new KyoKeyVO('O', 48);
    /** 主键盘 <code>1</code>。 */
    public static const N1:KyoKeyVO = new KyoKeyVO('1', 49);
    /** 主键盘 <code>2</code>。 */
    public static const N2:KyoKeyVO = new KyoKeyVO('2', 50);
    /** 主键盘 <code>3</code>。 */
    public static const N3:KyoKeyVO = new KyoKeyVO('3', 51);
    /** 主键盘 <code>4</code>。 */
    public static const N4:KyoKeyVO = new KyoKeyVO('4', 52);
    /** 主键盘 <code>5</code>。 */
    public static const N5:KyoKeyVO = new KyoKeyVO('5', 53);
    /** 主键盘 <code>6</code>。 */
    public static const N6:KyoKeyVO = new KyoKeyVO('6', 54);
    /** 主键盘 <code>7</code>。 */
    public static const N7:KyoKeyVO = new KyoKeyVO('7', 55);
    /** 主键盘 <code>8</code>。 */
    public static const N8:KyoKeyVO = new KyoKeyVO('8', 56);
    /** 主键盘 <code>9</code>。 */
    public static const N9:KyoKeyVO = new KyoKeyVO('9', 57);

    /** 小键盘 <code>0</code>。 */
    public static const Num0:KyoKeyVO = new KyoKeyVO('Num0', 96);
    /** 小键盘 <code>1</code>。 */
    public static const Num1:KyoKeyVO = new KyoKeyVO('Num1', 97);
    /** 小键盘 <code>2</code>。 */
    public static const Num2:KyoKeyVO = new KyoKeyVO('Num2', 98);
    /** 小键盘 <code>3</code>。 */
    public static const Num3:KyoKeyVO = new KyoKeyVO('Num3', 99);
    /** 小键盘 <code>4</code>。 */
    public static const Num4:KyoKeyVO = new KyoKeyVO('Num4', 100);
    /** 小键盘 <code>5</code>。 */
    public static const Num5:KyoKeyVO = new KyoKeyVO('Num5', 101);
    /** 小键盘 <code>6</code>。 */
    public static const Num6:KyoKeyVO = new KyoKeyVO('Num6', 102);
    /** 小键盘 <code>7</code>。 */
    public static const Num7:KyoKeyVO = new KyoKeyVO('Num7', 103);
    /** 小键盘 <code>8</code>。 */
    public static const Num8:KyoKeyVO = new KyoKeyVO('Num8', 104);
    /** 小键盘 <code>9</code>。 */
    public static const Num9:KyoKeyVO = new KyoKeyVO('Num9', 105);

    /** 字母 <code>A</code>。 */
    public static const A:KyoKeyVO = new KyoKeyVO('A', 65);
    /** 字母 <code>B</code>。 */
    public static const B:KyoKeyVO = new KyoKeyVO('B', 66);
    /** 字母 <code>C</code>。 */
    public static const C:KyoKeyVO = new KyoKeyVO('C', 67);
    /** 字母 <code>D</code>。 */
    public static const D:KyoKeyVO = new KyoKeyVO('D', 68);
    /** 字母 <code>E</code>。 */
    public static const E:KyoKeyVO = new KyoKeyVO('E', 69);
    /** 字母 <code>F</code>。 */
    public static const F:KyoKeyVO = new KyoKeyVO('F', 70);
    /** 字母 <code>G</code>。 */
    public static const G:KyoKeyVO = new KyoKeyVO('G', 71);
    /** 字母 <code>H</code>。 */
    public static const H:KyoKeyVO = new KyoKeyVO('H', 72);
    /** 字母 <code>I</code>。 */
    public static const I:KyoKeyVO = new KyoKeyVO('I', 73);
    /** 字母 <code>J</code>。 */
    public static const J:KyoKeyVO = new KyoKeyVO('J', 74);
    /** 字母 <code>K</code>。 */
    public static const K:KyoKeyVO = new KyoKeyVO('K', 75);
    /** 字母 <code>L</code>。 */
    public static const L:KyoKeyVO = new KyoKeyVO('L', 76);
    /** 字母 <code>M</code>。 */
    public static const M:KyoKeyVO = new KyoKeyVO('M', 77);
    /** 字母 <code>N</code>。 */
    public static const N:KyoKeyVO = new KyoKeyVO('N', 78);
    /** 字母 <code>O</code>。 */
    public static const O:KyoKeyVO = new KyoKeyVO('O', 79);
    /** 字母 <code>P</code>。 */
    public static const P:KyoKeyVO = new KyoKeyVO('P', 80);
    /** 字母 <code>Q</code>。 */
    public static const Q:KyoKeyVO = new KyoKeyVO('Q', 81);
    /** 字母 <code>R</code>。 */
    public static const R:KyoKeyVO = new KyoKeyVO('R', 82);
    /** 字母 <code>S</code>。 */
    public static const S:KyoKeyVO = new KyoKeyVO('S', 83);
    /** 字母 <code>T</code>。 */
    public static const T:KyoKeyVO = new KyoKeyVO('T', 84);
    /** 字母 <code>U</code>。 */
    public static const U:KyoKeyVO = new KyoKeyVO('U', 85);
    /** 字母 <code>V</code>。 */
    public static const V:KyoKeyVO = new KyoKeyVO('V', 86);
    /** 字母 <code>W</code>。 */
    public static const W:KyoKeyVO = new KyoKeyVO('W', 87);
    /** 字母 <code>X</code>。 */
    public static const X:KyoKeyVO = new KyoKeyVO('X', 88);
    /** 字母 <code>Y</code>。 */
    public static const Y:KyoKeyVO = new KyoKeyVO('Y', 89);
    /** 字母 <code>Z</code>。 */
    public static const Z:KyoKeyVO = new KyoKeyVO('Z', 90);

    /** 方向键上。 */
    public static const UP:KyoKeyVO = new KyoKeyVO('UP', 38);
    /** 方向键下。 */
    public static const DOWN:KyoKeyVO = new KyoKeyVO('DOWN', 40);
    /** 方向键左。 */
    public static const LEFT:KyoKeyVO = new KyoKeyVO('LEFT', 37);
    /** 方向键右。 */
    public static const RIGHT:KyoKeyVO = new KyoKeyVO('RIGHT', 39);

    /** Delete。 */
    public static const Delete:KyoKeyVO = new KyoKeyVO('DELETE', 46);
    /** End。 */
    public static const End:KyoKeyVO = new KyoKeyVO('END', 35);
    /** PageDown。 */
    public static const PageDown:KyoKeyVO = new KyoKeyVO('PAGEDOWN', 34);
    /** PageUp。 */
    public static const PageUp:KyoKeyVO = new KyoKeyVO('PAGEUP', 33);
    /** Insert。 */
    public static const Insert:KyoKeyVO = new KyoKeyVO('INSERT', 45);
    /** Home。 */
    public static const Home:KyoKeyVO = new KyoKeyVO('HOME', 36);

    /** 空格。 */
    public static const SPACE:KyoKeyVO = new KyoKeyVO('SPACE', 32);

    /** @private 供 code2name 检索的键列表（不含 SPACE） */
    private static var _keyArray:Array = [
        N0, N1, N2, N3, N4, N5, N6, N7, N8, N9,
        Num0, Num1, Num2, Num3, Num4, Num5, Num6, Num7, Num8, Num9,
        A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W, X, Y, Z,
        UP, DOWN, LEFT, RIGHT,
        Delete, End, PageDown, PageUp, Insert, Home
    ];

    /**
     * 按 keyCode 查键名。
     * @param code 键盘 keyCode。
     * @return 键名；未收录则 <code>null</code>（不含 SPACE）。
     * @example
     * <listing version="3.0">
     * KyoKeyCode.code2name(65); // 'A'
     * </listing>
     */
    public static function code2name(code:int):String {
        for each(var i:KyoKeyVO in _keyArray) {
            if (i.code == code) {
                return i.name;
            }
        }
        return null;
    }

}
}
