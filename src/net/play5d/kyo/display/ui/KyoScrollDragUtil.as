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
import flash.display.Stage;
import flash.geom.Point;
import flash.geom.Rectangle;

/**
 * 滚动面板 / 拖拽列表共用的拖拽判定与坐标辅助。
 *
 * <p>供 <code>KyoScrollPane</code>、<code>IPhoneScrollPane</code>、<code>KyoDragList</code> 等复用；
 * 不改变各组件自身的惯性 / 回弹策略。</p>
 *
 * @see KyoDragType
 * @see KyoScrollPane
 * @see IPhoneScrollPane
 * @see KyoDragList
 */
public class KyoScrollDragUtil {
    /**
     * 拖拽类型是否包含水平轴。
     * @param dragType <code>KyoDragType</code> 常量。
     * @return 是否允许水平。
     * @example
     * <listing version="3.0">
     * KyoScrollDragUtil.allowH(KyoDragType.DRAG_TYPE_BOTH); // true
     * </listing>
     */
    public static function allowH(dragType:int):Boolean {
        return dragType == KyoDragType.DRAG_TYPE_H || dragType == KyoDragType.DRAG_TYPE_BOTH;
    }

    /**
     * 拖拽类型是否包含垂直轴。
     * @param dragType <code>KyoDragType</code> 常量。
     * @return 是否允许垂直。
     * @example
     * <listing version="3.0">
     * KyoScrollDragUtil.allowV(KyoDragType.DRAG_TYPE_V); // true
     * </listing>
     */
    public static function allowV(dragType:int):Boolean {
        return dragType == KyoDragType.DRAG_TYPE_V || dragType == KyoDragType.DRAG_TYPE_BOTH;
    }

    /**
     * 相对按下点的鼠标位移（按下坐标减当前坐标）。
     * @param down 按下时舞台坐标。
     * @param stageX 当前舞台 mouseX。
     * @param stageY 当前舞台 mouseY。
     * @param hEnable 为 <code>false</code> 时水平分量置 0。
     * @param vEnable 为 <code>false</code> 时垂直分量置 0。
     * @return 位移点。
     * @example
     * <listing version="3.0">
     * var d:Point = KyoScrollDragUtil.mouseDelta(down, stage.mouseX, stage.mouseY);
     * </listing>
     */
    public static function mouseDelta(
        down   :Point,
        stageX :Number,
        stageY :Number,
        hEnable:Boolean = true,
        vEnable:Boolean = true
    ):Point {
        return new Point(
            hEnable ? down.x - stageX : 0,
            vEnable ? down.y - stageY : 0
        );
    }

    /**
     * 位移是否超过拖拽阈值。
     * @param xx 水平位移。
     * @param yy 垂直位移。
     * @param dragPixel 阈值像素。
     * @param hEnable 是否检测水平。
     * @param vEnable 是否检测垂直。
     * @return 是否超过阈值。
     * @example
     * <listing version="3.0">
     * KyoScrollDragUtil.exceedsThreshold(6, 0, 5, true, false); // true
     * </listing>
     */
    public static function exceedsThreshold(
        xx       :Number,
        yy       :Number,
        dragPixel:int,
        hEnable  :Boolean,
        vEnable  :Boolean
    ):Boolean {
        if (hEnable && Math.abs(xx) > dragPixel) {
            return true;
        }
        if (vEnable && Math.abs(yy) > dragPixel) {
            return true;
        }

        return false;
    }

    /**
     * 更新拖拽状态：首次超过阈值时置为拖拽中，并关闭舞台 <code>mouseChildren</code>。
     * @param dragging 当前是否已在拖拽。
     * @param xx 水平位移。
     * @param yy 垂直位移。
     * @param dragPixel 阈值像素。
     * @param hEnable 是否检测水平。
     * @param vEnable 是否检测垂直。
     * @param stage 舞台；可省略。
     * @return 更新后的拖拽状态。
     * @example
     * <listing version="3.0">
     * _dragging = KyoScrollDragUtil.updateDragging(_dragging, xx, yy, 5, true, true, stage);
     * </listing>
     */
    public static function updateDragging(
        dragging :Boolean,
        xx       :Number,
        yy       :Number,
        dragPixel:int,
        hEnable  :Boolean,
        vEnable  :Boolean,
        stage    :Stage = null
    ):Boolean {
        if (!dragging && exceedsThreshold(xx, yy, dragPixel, hEnable, vEnable)) {
            dragging = true;
        }
        if (dragging) {
            setStageMouseChildren(stage, false);
        }

        return dragging;
    }

    /**
     * 设置舞台 <code>mouseChildren</code>（stage 为空则忽略）。
     * @param stage 舞台。
     * @param enabled 是否启用子项鼠标。
     * @example
     * <listing version="3.0">
     * KyoScrollDragUtil.setStageMouseChildren(stage, true);
     * </listing>
     */
    public static function setStageMouseChildren(stage:Stage, enabled:Boolean):void {
        if (stage) {
            stage.mouseChildren = enabled;
        }
    }

    /**
     * 将 scrollRect 原点夹紧到可滚动范围（内容未超出时右/下界按 0）。
     * @param rect 待夹紧矩形（原地修改）。
     * @param contentW 内容宽。
     * @param contentH 内容高。
     * @param viewW 可视宽。
     * @param viewH 可视高。
     * @example
     * <listing version="3.0">
     * KyoScrollDragUtil.clampScrollOrigin(rect, cw, ch, vw, vh);
     * </listing>
     */
    public static function clampScrollOrigin(
        rect    :Rectangle,
        contentW:Number,
        contentH:Number,
        viewW   :Number,
        viewH   :Number
    ):void {
        var maxX:Number = contentW - viewW;
        var maxY:Number = contentH - viewH;

        if (rect.x > maxX) {
            rect.x = maxX;
        }
        if (rect.y > maxY) {
            rect.y = maxY;
        }
        if (rect.x < 0) {
            rect.x = 0;
        }
        if (rect.y < 0) {
            rect.y = 0;
        }
    }

    /**
     * 速度分量是否均接近静止。
     * @param spdX 水平速度。
     * @param spdY 垂直速度；一维场景可传 0。
     * @param threshold 阈值，默认 1。
     * @return 是否接近静止。
     * @example
     * <listing version="3.0">
     * KyoScrollDragUtil.isNearlyStopped(0.5, 0.2); // true
     * </listing>
     */
    public static function isNearlyStopped(spdX:Number, spdY:Number = 0, threshold:Number = 1):Boolean {
        return Math.abs(spdX) < threshold && Math.abs(spdY) < threshold;
    }

}
}

