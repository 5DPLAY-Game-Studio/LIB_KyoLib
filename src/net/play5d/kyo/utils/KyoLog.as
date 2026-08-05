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
import flash.display.Sprite;
import flash.text.TextField;

/**
 * 简易日志：累积字符串，可选 <code>trace</code>，并可在容器上叠加显示。
 *
 * @see #log()
 * @see #showLog()
 * @see #toggleLog()
 */
public class KyoLog {
    /**
     * 为 <code>true</code> 时同步 <code>trace</code>。
     * @default true
     */
    public static var traceLog:Boolean = true;

    /** @private */
    private static var _log:String = '';
    /** @private */
    private static var _logTxt:TextField;

    /**
     * 追加一行日志。
     * @param params 参数，以空格拼接。
     * @example
     * <listing version="3.0">
     * KyoLog.log('ready', 1);
     * </listing>
     */
    public static function log(...params):void {
        var logStr:String = params.join(' ');
        _log += logStr + '\n';
        updateLogTxt();

        if (traceLog) {
            trace(logStr);
        }
    }

    /**
     * 取得累积日志全文。
     * @return 日志字符串。
     * @example
     * <listing version="3.0">
     * var s:String = KyoLog.getLog();
     * </listing>
     */
    public static function getLog():String {
        return _log;
    }

    /**
     * 切换日志面板显示。
     * @param ct 父容器。
     * @example
     * <listing version="3.0">
     * KyoLog.toggleLog(root);
     * </listing>
     */
    public static function toggleLog(ct:Sprite):void {
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

        if (!_logTxt) {
            _logTxt           = new TextField();
            _logTxt.textColor = KyoColor.WHITE;
            _logTxt.multiline = true;
            var wh:Number     = ct.stage ? ct.stage.stageWidth : ct.width;
            _logTxt.width     = wh / 2;
        }

        var sp:Sprite = new Sprite();
        sp.name       = 'kyo_log_sprite';
        sp.addChild(_logTxt);
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
    }

    /** @private */
    private static function updateLogTxt():void {
        if (!_logTxt) {
            return;
        }
        _logTxt.text   = _log;
        _logTxt.height = _logTxt.textHeight + 10;

        var sp:Sprite = _logTxt.parent as Sprite;
        if (sp) {
            sp.graphics.clear();
            sp.graphics.beginFill(KyoColor.BLACK, 0.5);
            sp.graphics.drawRect(0, 0, _logTxt.width, _logTxt.height);
            sp.graphics.endFill();
        }
    }

}
}

