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

package net.play5d.kyo.effect {
import com.greensock.TweenLite;

import flash.text.TextField;

/**
 * 文字显示效果工具。
 * @author kyo
 * @see #showOneByOne()
 */
public class WordEffect {
    /**
     * 将文本框内容按字逐个追加显示。
     *
     * <p>会先清空 <code>txt.text</code>，再按间隔把原文字逐字 <code>appendText</code> 回去；最后一个字出现后调用 <code>finish</code>（若有）。</p>
     *
     * @param txt 目标文本框（需已设好完整 <code>text</code>）。
     * @param gapTime 相邻两字之间的间隔（秒），默认 0.03。
     * @param finish 全部显示完成后的无参回调，可选。
     * @example
     * <listing version="3.0">
     * tf.text = '你好世界';
     * WordEffect.showOneByOne(tf, 0.05, onDone);
     * </listing>
     */
    public static function showOneByOne(txt:TextField, gapTime:Number = 0.03, finish:Function = null):void {
        var str:String = txt.text;
        var len:int    = str.length;
        txt.text       = '';
        for (var i:int; i < len; i++) {
            var f:Function;
            if (finish != null) {
                if (i == len - 1) {
                    f = finish;
                }
            }
            TweenLite.delayedCall(i * gapTime, function (ci:int):void {
                txt.appendText(str.charAt(ci));
                if (f != null) {
                    f();
                }
            }, [i]);
        }
    }
}
}
