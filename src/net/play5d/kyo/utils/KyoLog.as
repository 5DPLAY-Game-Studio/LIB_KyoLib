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
import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.text.TextField;

/**
 * 简易日志：累积字符串，可选 <code>trace</code>，并可在容器上叠加显示。
 *
 * @see #log()
 * @see #showLog()
 * @see #toogleLog()
 */
public class KyoLog {
    /**
     * 为 <code>true</code> 时同步 <code>trace</code>。
     * @default true
     */
    public static var tracelog:Boolean = true;

    /** @private */
    private static var _log:String = '';
    /** @private */
    private static var _logtxt:TextField;

    /**
     * 追加一行日志。
     * @param params 参数，以空格拼接。
     * @example
     * <listing version="3.0">
     * KyoLog.log('ready', 1);
     * </listing>
     */
    public static function log(...params):void {
        var logstr:String = params.join(' ');
        _log += logstr + '\n';
        updateLogTxt();

        if (tracelog) {
            trace(logstr);
        }
    }

    /**
     * 取得累积日志全文。
     * @return 日志字符串。
     * @example
     * <listing version="3.0">
     * var s:String = KyoLog.getlog();
     * </listing>
     */
    public static function getlog():String {
        return _log;
    }

    /**
     * 切换日志面板显示（历史拼写 <code>toogle</code>）。
     * @param ct 父容器。
     * @example
     * <listing version="3.0">
     * KyoLog.toogleLog(root);
     * </listing>
     */
    public static function toogleLog(ct:Sprite):void {
        var sp:DisplayObject = ct.getChildByName('kyo_log_sprite');
        if (!sp) {
            showLog(ct);
        }
        else {
            hideLog(ct);
        }
    }

    /**
     * 在容器上显示半透明日志层。
     * @param ct 父容器。
     * @example
     * <listing version="3.0">
     * KyoLog.showLog(root);
     * </listing>
     */
    public static function showLog(ct:Sprite):void {
        hideLog(ct);

        if (!_logtxt) {
            _logtxt           = new TextField();
            _logtxt.textColor = 0xFFFFFF;
            _logtxt.multiline = true;
            var wh:Number     = ct.stage ? ct.stage.stageWidth : ct.width;
            _logtxt.width     = wh / 2;
        }

        var sp:Sprite = new Sprite();
        sp.name       = 'kyo_log_sprite';
        sp.addChild(_logtxt);
        ct.addChild(sp);

        updateLogTxt();
    }

    /**
     * 隐藏日志层。
     * @param ct 父容器。
     * @example
     * <listing version="3.0">
     * KyoLog.hideLog(root);
     * </listing>
     */
    public static function hideLog(ct:Sprite):void {
        var sp:DisplayObject = ct.getChildByName('kyo_log_sprite');
        if (!sp) {
            return;
        }

        ct.removeChild(sp);
        sp = null;
    }

    /**
     * @private
     */
    private static function updateLogTxt():void {
        if (!_logtxt) {
            return;
        }
        _logtxt.text   = _log;
        _logtxt.height = _logtxt.textHeight + 10;

        var sp:Sprite = _logtxt.parent as Sprite;
        if (sp) {
            sp.graphics.clear();
            sp.graphics.beginFill(0, 0.5);
            sp.graphics.drawRect(0, 0, _logtxt.width, _logtxt.height);
            sp.graphics.endFill();
        }
    }

}
}
