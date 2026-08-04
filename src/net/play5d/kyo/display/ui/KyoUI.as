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
import com.greensock.TweenLite;

import flash.display.Sprite;
import flash.events.Event;
import flash.geom.Point;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;

import net.play5d.kyo.utils.KyoColor;

/**
 * 简易舞台弹层工具：提示框与确认框（依赖静态 <code>stage</code>）。
 *
 * @see #stage
 * @see #alert()
 * @see #confrim()
 * @see KyoSimpButton
 */
public class KyoUI {
    /**
     * 弹层父容器（需为已上舞台的 Sprite）。
     * @default null
     */
    public static var stage:Sprite;
    /**
     * <code>alert</code> 是否使用淡入淡出。
     * @default false
     */
    public static var tween:Boolean = false;
    /**
     * 弹层内按钮默认尺寸。
     * @default (50, 20)
     */
    public static var btnSize:Point = new Point(50, 20);

    /**
     * 显示仅含「确定」的提示框。
     * @param msg 文案。
     * @param width 框宽，默认 200。
     * @param height 框高，默认 100。
     * @example
     * <listing version="3.0">
     * KyoUI.stage = root;
     * KyoUI.alert('完成');
     * </listing>
     */
    public static function alert(msg:String, width:Number = 200, height:Number = 100):void {
        var sp:Sprite     = newBox(width, height);
        var txt:TextField = newTxt(msg, width);
        sp.addChild(txt);
        stage.addChild(sp);

        var btn:KyoSimpButton = new KyoSimpButton('确定', btnSize.x, btnSize.y);
        btn.x                 = (width - btn.width) / 2;
        btn.y                 = height - btn.height - 10;
        btn.onClick(close);
        sp.addChild(btn);

        if (tween) {
            sp.alpha = 0;
            TweenLite.to(sp, .5, {alpha: 1});
        }

        function close(e:Event = null):void {
            if (tween) {
                TweenLite.to(sp, .5, {
                    alpha     : 0,
                    onComplete: function ():void {
                        stage.removeChild(sp);
                        sp = null;
                    }
                });
            }
            else {
                stage.removeChild(sp);
                sp = null;
            }
        }
    }

    /**
     * 显示「确定 / 取消」确认框。
     * @param msg 文案。
     * @param ok 确定回调，可选。
     * @param no 取消回调，可选。
     * @param width 框宽，默认 200。
     * @param height 框高，默认 100。
     * @example
     * <listing version="3.0">
     * KyoUI.confrim('删除？', onOk, onCancel);
     * </listing>
     */
    public static function confrim(
        msg   :String,
        ok    :Function = null,
        no    :Function = null,
        width :Number = 200,
        height:Number = 100
    ):void {
        var sp:Sprite     = newBox(width, height);
        var txt:TextField = newTxt(msg, width);
        sp.addChild(txt);
        stage.addChild(sp);

        var btny:KyoSimpButton = new KyoSimpButton('确定', btnSize.x, btnSize.y);
        btny.x                 = width - btny.width * 2 - 20;
        btny.y                 = height - btny.height - 10;
        btny.onClick(function ():void {
            if (ok != null) {
                ok();
            }
            close();
        });
        sp.addChild(btny);

        var btnn:KyoSimpButton = new KyoSimpButton('取消', btnSize.x, btnSize.y);
        btnn.x                 = width - btnn.width - 10;
        btnn.y                 = height - btnn.height - 10;
        btnn.onClick(function ():void {
            if (no != null) {
                no();
            }
            close();
        });
        sp.addChild(btnn);

        function close(e:Event = null):void {
            stage.removeChild(sp);
            sp = null;
        }
    }

    /**
     * @private 创建居中文本。
     */
    private static function newTxt(msg:String, width:Number):TextField {
        var tf:TextFormat     = new TextFormat();
        tf.align              = TextFormatAlign.CENTER;
        var txt:TextField     = new TextField();
        txt.defaultTextFormat = tf;
        txt.mouseEnabled      = false;
        txt.text              = msg;
        txt.width             = width;
        txt.height            = txt.textHeight + 5;
        txt.y                 = 10;

        return txt;
    }

    /**
     * @private 创建居中白底框。
     */
    private static function newBox(width:Number, height:Number):Sprite {
        var bg:Sprite = new Sprite();
        bg.graphics.lineStyle(1, KyoColor.BLACK);
        bg.graphics.beginFill(KyoColor.WHITE, 1);
        bg.graphics.drawRect(0, 0, width, height);
        bg.graphics.endFill();

        bg.x = (stage.stage.stageWidth - width) / 2;
        bg.y = (stage.stage.stageHeight - height) / 2;

        return bg;
    }

}
}
