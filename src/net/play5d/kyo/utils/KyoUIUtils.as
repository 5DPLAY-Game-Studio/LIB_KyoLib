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
import flash.display.DisplayObject;
import flash.geom.Point;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;

/**
 * UI 与 TextField 辅助。
 *
 * @see #setText()
 * @see #alignTexts()
 */
public class KyoUIUtils {
    /**
     * 按比例设置横向缩放；比例 &lt;= 0 时隐藏。
     * @param ui 目标显示对象。
     * @param per 0~1 比例。
     * @example
     * <listing version="3.0">
     * KyoUIUtils.setBarScaleX(bar, 0.5);
     * </listing>
     */
    public static function setBarScaleX(ui:DisplayObject, per:Number):void {
        if (per > 0) {
            ui.scaleX  = per;
            ui.visible = true;
        }
        else {
            ui.visible = false;
        }
    }

    /**
     * 设置 Flash UI 组件字体样式。
     * @param ui 组件实例。
     * @param font 写入 <code>TextFormat</code> 的属性对象；默认宋体 12。
     * @example
     * <listing version="3.0">
     * KyoUIUtils.setFlashUIFont(combo, {size: 14});
     * </listing>
     */
    public static function setFlashUIFont(ui:*, font:Object = null):void {
        var tft:TextFormat = new TextFormat();
        tft.font           = '宋体';
        tft.size           = 12;
        if (font) {
            KyoUtils.setValueByObject(tft, font);
        }

        try {
            ui.setStyle('textFormat', tft);
            ui.textField.setStyle('textFormat', tft);
            ui.dropdown.setRendererStyle('textFormat', tft);
        }
        catch (e:Error) {
        }
    }

    /**
     * 追加文本；若增加滚动行则改为换行追加。
     * @param textField 文本框。
     * @param text 追加内容。
     * @return 是否因换行而调整。
     * @example
     * <listing version="3.0">
     * KyoUIUtils.appendTextAutoLine(tf, 'hi');
     * </listing>
     */
    public static function appendTextAutoLine(textField:TextField, text:String):Boolean {
        var ll:int     = textField.maxScrollV;
        var tmp:String = textField.text;
        textField.appendText(text);
        if (textField.maxScrollV > ll) {
            textField.text = tmp + '\n' + text;

            return true;
        }

        return false;
    }

    /**
     * 在文本底部追加行，并裁掉顶部多余行以保持行数。
     * @param textField 文本框。
     * @param text 新行内容。
     * @param totalLines 目标行数（首次会预填空行）。
     * @param html 是否按 htmlText 追加。
     * @example
     * <listing version="3.0">
     * KyoUIUtils.appendTextBottom(tf, 'line', 5);
     * </listing>
     */
    public static function appendTextBottom(
            textField:TextField, text:String, totalLines:int, html:Boolean = false
    ):void {
        if (textField.numLines <= 1) {
            for (var i:int = 0; i < totalLines; i++) {
                if (html) {
                    textField.htmlText += '<br/>';
                }
                else {
                    textField.appendText('\n');
                }
            }
        }
        if (html) {
            textField.htmlText += text;
        }
        else {
            textField.appendText('\n' + text);
        }

        var m:int = textField.getLineOffset(1);
        if (m != -1) {
            textField.replaceText(0, m, '');
        }
    }

    /**
     * 设置 TextField 文本与是否可鼠标交互。
     * @param txt 文本框。
     * @param text 内容（经 <code>String(text)</code> 转换；<code>null</code> 会变成字符串 <code>'null'</code>）。
     * @param mouseEnabled 是否可交互。
     * @param nullText 历史参数；当前实现在 <code>String()</code> 之后判断，通常不会生效。
     * @param autoSize 是否自动缩小字号适配。
     * @example
     * <listing version="3.0">
     * KyoUIUtils.setText(tf, 'hi');
     * </listing>
     */
    public static function setText(
            txt:TextField, text:Object = '', mouseEnabled:Boolean = false, nullText:String = 'null',
            autoSize:Boolean = false
    ):void {
        var t:String = String(text);
        if (t == null) {
            t = nullText;
        }
        txt.mouseEnabled = mouseEnabled;
        txt.text         = t;

        if (autoSize) {
            textFieldAutoSize(txt);
        }
    }

    /**
     * 缩小字号直到文本宽/高适配 TextField。
     * @param txt 文本框。
     * @example
     * <listing version="3.0">
     * KyoUIUtils.textFieldAutoSize(tf);
     * </listing>
     */
    public static function textFieldAutoSize(txt:TextField):void {
        var tf:TextFormat = txt.getTextFormat();
        if (txt.multiline) {
            while (txt.textHeight > txt.height) {
                tf.size = int(tf.size) - 1;
                txt.setTextFormat(tf);
            }
        }
        else {
            while (txt.textWidth > txt.width) {
                tf.size = int(tf.size) - 1;
                txt.setTextFormat(tf);
            }
        }
    }

    /**
     * 按横向或纵向排列多个 TextField。
     * @param txts TextField 数组。
     * @param startPos 起始坐标；NaN 时取首项当前位置。
     * @param direct 0=横向，1=竖向。
     * @param autoSize 默认 <code>TextFieldAutoSize.LEFT</code>。
     * @param offset 宽高微调。
     * @example
     * <listing version="3.0">
     * KyoUIUtils.alignTexts([tf1, tf2], NaN, 0);
     * </listing>
     */
    public static function alignTexts(
            txts:Array, startPos:Number = NaN, direct:int = 0, autoSize:String = null, offset:Point = null
    ):void {
        autoSize ||= TextFieldAutoSize.LEFT;

        var len:Number = startPos;
        if (isNaN(len)) {
            var f:TextField = txts[0] as TextField;
            len             = direct == 0 ? f.x : f.y;
        }

        for each (var i:TextField in txts) {
            i.autoSize = autoSize;
            if (offset) {
                i.width += offset.x;
                i.height += offset.y;
            }

            switch (direct) {
            case 0:
                i.x = len;
                len += i.width;
                break;
            case 1:
                i.y = len;
                len += i.height;
                break;
            }
        }
    }

}
}

