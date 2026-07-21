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
import flash.events.MouseEvent;
import flash.geom.Rectangle;

/**
 * 鼠标拖拽工具：底层事件挂钩与 <code>startDrag</code> 封装。
 *
 * @see #dragBase()
 * @see #dragSimple()
 */
public class KyoDragUtils {
    /**
     * 在按下对象上挂钩 DOWN/MOVE/UP；回调返回 <code>false</code> 可取消后续。
     * @param downmc 按下目标。
     * @param onDown 按下回调；可返回 Boolean。
     * @param onUp 抬起回调；可返回 Boolean。
     * @param onMove 移动回调。
     * @example
     * <listing version="3.0">
     * KyoDragUtils.dragBase(mc, onDown, onUp, onMove);
     * </listing>
     */
    public static function dragBase(downmc:DisplayObject, onDown:Function = null, onUp:Function = null,
                                    onMove:Function = null
    ):void {
        downmc.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);

        function onMouseDown(e:MouseEvent):void {
            if (!downmc.stage) {
                return;
            }
            if (onDown != null) {
                var dv:* = onDown();
                if (dv is Boolean && dv == false) {
                    return;
                }
            }

            if (downmc.stage) {
                downmc.stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
                downmc.stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
            }
            else {
                downmc.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
                downmc.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
            }

        }

        function onMouseUp(e:MouseEvent):void {
            if (onUp != null) {
                var uv:* = onUp();
                if (uv is Boolean && uv == false) {
                    return;
                }
            }

            if (downmc.stage) {
                downmc.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
                downmc.stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
            }
            else {
                downmc.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
                downmc.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
            }

        }

        function onMouseMove(e:MouseEvent):void {
            if (onMove != null) {
                onMove();
            }
        }
    }

    /**
     * 基于 <code>dragBase</code> 调用 <code>startDrag</code> / <code>stopDrag</code>。
     * @param downmc 按下的 Sprite。
     * @param params 可选键：<code>onDown/onUp/onMove/dragmc/bounds/lockCenter</code>。
     * @example
     * <listing version="3.0">
     * KyoDragUtils.dragSimple(panel, {bounds: rect});
     * </listing>
     */
    public static function dragSimple(downmc:Sprite, params:Object = null):void {
        var onDown:Function, onUp:Function, onMove:Function;
        var dragmc:Sprite, bounds:Rectangle, lockCenter:Boolean;
        if (params) {
            onDown     = params.onDown;
            onUp       = params.onUp;
            onMove     = params.onMove;
            dragmc     = params.dragmc;
            bounds     = params.bounds;
            lockCenter = params.lockCenter;
        }

        dragmc ||= downmc;
        dragBase(downmc, simDown, simUp, simMove);

        function simDown():Boolean {
            if (onDown != null && !onDown()) {
                return false;
            }
            dragmc.startDrag(lockCenter, bounds);
            return true;
        }

        function simUp():Boolean {
            if (onUp != null && !onUp()) {
                return false;
            }
            dragmc.stopDrag();
            return true;
        }

        function simMove():void {
            if (onMove != null) {
                onMove();
            }
        }
    }

    /**
     * 构造函数（本类以静态方法使用，通常无需实例化）。
     */
    public function KyoDragUtils() {
    }

}
}
