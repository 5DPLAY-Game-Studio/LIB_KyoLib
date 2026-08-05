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
 * @see #confirm()
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
        var sp:Sprite = openPanel(msg, width, height);

        var btn:KyoSimpButton = new KyoSimpButton('确定', btnSize.x, btnSize.y);
        btn.x = (width - btn.width) / 2;
        btn.y = height - btn.height - 10;
        btn.onClick(function (e:Event = null):void {
            closePanel(sp, true);
        });
        sp.addChild(btn);

        if (tween) {
            sp.alpha = 0;
            TweenLite.to(sp, .5, {alpha: 1});
        }
    }

    /**
     * 显示「确定 / 取消」确认框。
     * @param msg 文案。
     * @param ok 确定回调，可选。
     * @param cancel 取消回调，可选。
     * @param width 框宽，默认 200。
     * @param height 框高，默认 100。
     * @example
     * <listing version="3.0">
     * KyoUI.confirm('删除？', onOk, onCancel);
     * </listing>
     */
    public static function confirm(
        msg   :String,
        ok    :Function = null,
        cancel:Function = null,
        width :Number = 200,
        height:Number = 100
    ):void {
        var sp:Sprite = openPanel(msg, width, height);

        var okBtn:KyoSimpButton = new KyoSimpButton('确定', btnSize.x, btnSize.y);
        okBtn.x = width - okBtn.width * 2 - 20;
        okBtn.y = height - okBtn.height - 10;
        okBtn.onClick(function ():void {
            if (ok != null) {
                ok();
            }
            closePanel(sp, false);
        });
        sp.addChild(okBtn);

        var cancelBtn:KyoSimpButton = new KyoSimpButton('取消', btnSize.x, btnSize.y);
        cancelBtn.x = width - cancelBtn.width - 10;
        cancelBtn.y = height - cancelBtn.height - 10;
        cancelBtn.onClick(function ():void {
            if (cancel != null) {
                cancel();
            }
            closePanel(sp, false);
        });
        sp.addChild(cancelBtn);
    }

    /**
     * @private 创建文案框并加入舞台。
     */
    private static function openPanel(msg:String, width:Number, height:Number):Sprite {
        var sp:Sprite = newBox(width, height);
        sp.addChild(newTxt(msg, width));
        stage.addChild(sp);

        return sp;
    }

    /**
     * @private 关闭弹层；可选淡出。
     */
    private static function closePanel(sp:Sprite, useTween:Boolean):void {
        if (useTween && tween) {
            TweenLite.to(sp, .5, {
                alpha     : 0,
                onComplete: function ():void {
                    if (sp.parent) {
                        stage.removeChild(sp);
                    }
                }
            });
        }
        else {
            if (sp.parent) {
                stage.removeChild(sp);
            }
        }
    }

    /**
     * @private 创建居中文本。
     */
    private static function newTxt(msg:String, width:Number):TextField {
        var tf:TextFormat = new TextFormat();
        tf.align          = TextFormatAlign.CENTER;

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

