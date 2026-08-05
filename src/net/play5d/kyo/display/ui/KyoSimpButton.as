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

package net.play5d.kyo.display.ui {
import flash.display.GradientType;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.geom.Matrix;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;

import net.play5d.kyo.utils.KyoColor;

/**
 * 简易程序绘制按钮：渐变底 + 居中标签，悬停变色。
 *
 * @see #onClick()
 * @see #btnWidth
 * @see #btnHeight
 */
public class KyoSimpButton extends Sprite {
    /**
     * @param label 按钮文字。
     * @param width 宽，默认 50。
     * @param height 高，默认 20。
     */
    public function KyoSimpButton(label:String, width:Number = 50, height:Number = 20) {
        super();

        btnWidth  = width;
        btnHeight = height;

        drawBg([KyoColor.WHITE, KyoColor.SILVER]);

        var txt:TextField = new TextField();
        var tf:TextFormat = new TextFormat();
        tf.align          = TextFormatAlign.CENTER;
        tf.size           = 12;
        txt.defaultTextFormat = tf;

        txt.text   = label;
        txt.width  = width;
        txt.height = txt.textHeight + 5;
        txt.y      = (height - txt.height) / 2;

        addChild(txt);

        buttonMode    = true;
        mouseChildren = false;

        addEventListener(MouseEvent.MOUSE_OVER, overHandler);
        addEventListener(MouseEvent.MOUSE_OUT, overHandler);
    }

    /**
     * 按钮宽度。
     */
    public var btnWidth:Number;
    /**
     * 按钮高度。
     */
    public var btnHeight:Number;

    /**
     * 注册点击回调。
     * @param fun 监听 <code>MouseEvent.CLICK</code> 的函数。
     * @example
     * <listing version="3.0">
     * btn.onClick(onBtnClick);
     * </listing>
     */
    public function onClick(fun:Function):void {
        addEventListener(MouseEvent.CLICK, fun);
    }

    /**
     * @private 绘制线性渐变背景。
     */
    private function drawBg(color:Array):void {
        graphics.lineStyle(1, KyoColor.DIM_GRAY);

        var mtx:Matrix = new Matrix();
        mtx.createGradientBox(btnWidth, btnHeight, Math.PI, 0, 0);

        graphics.beginGradientFill(GradientType.LINEAR, color, [1, 1], [0, 255], mtx);
        graphics.drawRect(0, 0, btnWidth, btnHeight);
        graphics.endFill();
    }

    /**
     * @private 悬停 / 移出换底色。
     */
    private function overHandler(e:MouseEvent):void {
        if (e.type == MouseEvent.MOUSE_OVER) {
            drawBg([KyoColor.WHITE, KyoColor.WHITE_SMOKE]);
        }
        else {
            drawBg([KyoColor.WHITE, KyoColor.SILVER]);
        }
    }

}
}

