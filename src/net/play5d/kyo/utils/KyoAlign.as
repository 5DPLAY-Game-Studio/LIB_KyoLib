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
import flash.geom.Point;

/**
 * 显示对象对齐工具；目前仅实现水平 / 垂直居中。
 *
 * @see #centerH()
 * @see #centerW()
 */
public class KyoAlign {
    /**
     * 左对齐（当前为空实现）。
     * @param A 要对齐的对象。
     * @param B 参照对象。
     * @example
     * <listing version="3.0">
     * KyoAlign.left(a, b);
     * </listing>
     */
    public static function left(A:DisplayObject, B:DisplayObject):void {
    }

    /**
     * 右对齐（当前为空实现）。
     * @param A 要对齐的对象。
     * @param B 参照对象。
     * @example
     * <listing version="3.0">
     * KyoAlign.right(a, b);
     * </listing>
     */
    public static function right(A:DisplayObject, B:DisplayObject):void {
    }

    /**
     * 垂直居中：将 <code>A</code> 相对参照高度居中。
     * @param A 要对齐的对象。
     * @param B 参照高度：<code>Number</code>、高度区间 <code>Point</code>（y-x）、或 <code>DisplayObject</code>。
     * @example
     * <listing version="3.0">
     * KyoAlign.centerH(label, panel);
     * </listing>
     */
    public static function centerH(A:DisplayObject, B:Object):void {
        var Bnum:Number;
        if (B is Number) {
            Bnum = B as Number;
        }
        if (B is Point) {
            var bp:Point = B as Point;
            Bnum         = bp.y - bp.x;
        }
        if (B is DisplayObject) {
            A.y  = (B as DisplayObject).y;
            Bnum = (B as DisplayObject).height;
        }
        var diff:Number = Bnum - A.height;
        A.y += diff / 2;
    }

    /**
     * 顶对齐（当前为空实现）。
     * @param A 要对齐的对象。
     * @param B 参照对象。
     * @example
     * <listing version="3.0">
     * KyoAlign.up(a, b);
     * </listing>
     */
    public static function up(A:DisplayObject, B:DisplayObject):void {
    }

    /**
     * 底对齐（当前为空实现）。
     * @param A 要对齐的对象。
     * @param B 参照对象。
     * @example
     * <listing version="3.0">
     * KyoAlign.down(a, b);
     * </listing>
     */
    public static function down(A:DisplayObject, B:DisplayObject):void {
    }

    /**
     * 水平居中：将 <code>A</code> 相对参照宽度居中。
     * @param A 要对齐的对象。
     * @param B 参照宽度：<code>Number</code>、宽度区间 <code>Point</code>（y-x）、或 <code>DisplayObject</code>。
     * @example
     * <listing version="3.0">
     * KyoAlign.centerW(btn, stage.stageWidth);
     * </listing>
     */
    public static function centerW(A:DisplayObject, B:Object):void {
        var Bnum:Number;
        if (B is Number) {
            Bnum = B as Number;
        }
        if (B is Point) {
            var bp:Point = B as Point;
            Bnum         = bp.y - bp.x;
        }
        if (B is DisplayObject) {
            A.x  = (B as DisplayObject).x;
            Bnum = (B as DisplayObject).width;
        }
        var diff:Number = Bnum - A.width;
        A.x += diff / 2;
    }

}
}
