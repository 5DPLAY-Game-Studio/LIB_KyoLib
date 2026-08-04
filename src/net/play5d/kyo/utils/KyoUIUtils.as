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
import flash.geom.Point;
import flash.text.TextFieldAutoSize;
import flash.text.TextField;
import flash.display.DisplayObject;
import flash.text.TextFormat;

/**
 * UI 与 TextField 辅助。
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
     * @param txtfield 文本框。
     * @param text 追加内容。
     * @return 是否因换行而调整。
     * @example
     * <listing version="3.0">
     * KyoUIUtils.appendTextAutoLine(tf, 'hi');
     * </listing>
     */
    public static function appendTextAutoLine(txtfield:TextField, text:String):Boolean {
        var ll:int     = txtfield.maxScrollV;
        var tmp:String = txtfield.text;
        txtfield.appendText(text);
        if (txtfield.maxScrollV > ll) {
            txtfield.text = tmp + '\n' + text;
            return true;
        }
        return false;
    }
/**
     * 在文本底部追加行，并裁掉顶部多余行以保持行数。
     * @param textfield 文本框。
     * @param text 新行内容。
     * @param totalLines 目标行数（首次会预填空行）。
     * @param html 是否按 htmlText 追加。
     * @example
     * <listing version="3.0">
     * KyoUIUtils.appendTextBottom(tf, 'line', 5);
     * </listing>
     */
    public static function appendTextBottom(textfield:TextField, text:String, totalLines:int,
                                            html:Boolean = false
    ):void {
        if (textfield.numLines <= 1) {
            for (var i:int; i < totalLines; i++) {
                if (html) {
                    textfield.htmlText += '<br/>';
                }
                else {
                    textfield.appendText('\n');
                }
            }
        }
        if (html) {
            textfield.htmlText += text;
        }
        else {
            textfield.appendText('\n' + text);
        }
        var m:int = textfield.getLineOffset(1);
        if (m != -1) {
            textfield.replaceText(0, m, '');
        }
    }
/**
     * 设置 TextField 文本与是否可鼠标交互。
     * @param txt 文本框。
     * @param text 内容。
     * @param mouseEnabled 是否可交互。
     * @param nulltxt text 为 null 时的占位。
     * @param autoSize 是否自动缩小字号适配。
     * @example
     * <listing version="3.0">
     * KyoUIUtils.setText(tf, 'hi');
     * </listing>
     */
    public static function setText(txt:TextField, text:Object = '', mouseEnabled:Boolean = false,
                                   nulltxt:String = 'null', autoSize:Boolean = false
    ):void {
        var t:String = String(text);
        if (t == null) {
            t = nulltxt;
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
        if (txt.multiline == true) {
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
     * 排序多个TextField
     * @param txts TextField数组
     * @param startPos 开始位置
     * @param direct 排序方向；0=横向,1=竖向
     * @param autoSize 默认：TextFieldAutoSize.LEFT
     * @param offset TextField宽高调整
     * @example
     * <listing version="3.0">
     * KyoUIUtils.alignTexts([tf1, tf2], NaN, 0);
     * </listing>
     */
    public static function alignTexts(txts:Array, startPos:Number = NaN, direct:int = 0, autoSize:String = null,
                                      offset:Point                                                       = null
    ):void {
        autoSize ||= TextFieldAutoSize.LEFT;

        var len:Number = startPos;

        if (isNaN(len)) {
            var f:TextField = txts[0] as TextField;
            len             = direct == 0 ? f.x : f.y;
        }

        for each(var i:TextField in txts) {
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
