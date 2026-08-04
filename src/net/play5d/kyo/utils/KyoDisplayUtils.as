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
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.FrameLabel;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.filters.BitmapFilter;
import flash.filters.ColorMatrixFilter;
import flash.geom.ColorTransform;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.media.SoundTransform;
import flash.system.Capabilities;

/**
 * 显示对象、位图绘制、MovieClip、碰撞检测与厘米像素换算。
 */
public class KyoDisplayUtils {
    /**
     * 通过 AMF 序列化做深度拷贝（委托 <code>KyoUtils.clone</code>）。
     * @param object 源对象。
     * @return 拷贝后的显示对象；失败时为 <code>null</code>。
     * @example
     * <listing version="3.0">
     * var c:DisplayObject = KyoDisplayUtils.clone(obj);
     * </listing>
     * @see net.play5d.kyo.utils.KyoUtils#clone()
     */
    public static function clone(object:Object):DisplayObject {
        return KyoUtils.clone(object) as DisplayObject;
    }

    /**
     * 按构造函数新建实例并复制 transform / filters 等；可选加入父级。
     * @param target 源显示对象。
     * @param autoAdd 为 <code>true</code> 且有 parent 时加入同一显示列表。
     * @return 副本。
     * @example
     * <listing version="3.0">
     * var d:DisplayObject = KyoDisplayUtils.duplicateDisplayObject(mc, true);
     * </listing>
     */
    public static function duplicateDisplayObject(target:DisplayObject, autoAdd:Boolean = false):DisplayObject {
        var targetClass:Class       = Object(target).constructor;
        var duplicate:DisplayObject = new targetClass();

        duplicate.transform        = target.transform;
        duplicate.filters          = target.filters;
        duplicate.cacheAsBitmap    = target.cacheAsBitmap;
        duplicate.opaqueBackground = target.opaqueBackground;

        if (target.scale9Grid) {
            var rect:Rectangle   = target.scale9Grid;
            // Flash 9 bug where returned scale9Grid is 20x larger than assigned
            rect.x /= 20;
            rect.y /= 20;
            rect.width /= 20;
            rect.height /= 20;
            duplicate.scale9Grid = rect;
        }

        if (autoAdd && target.parent) {
            target.parent.addChild(duplicate);
        }

        return duplicate;
    }

    /**
     * 判断两个矩形是否碰撞（支持旋转）。
     * @param obj1 含 <code>x/y/width/height</code>（必填）；可选 <code>scaleX/rotation/radian/originX/originY</code>。
     * @param obj2 同 obj1。
     * @return 是否碰撞。
     * @throws Error 缺少 x/y/width/height。
     * @example
     * <listing version="3.0">
     * var hit:Boolean = KyoDisplayUtils.rotationRectCollide(a, b);
     * </listing>
     */
    public static function rotationRectCollide(obj1:Object, obj2:Object):Boolean {
        if (obj1 == null || obj2 == null) {
            return false;
        }

        var cosCache:Object = {};
        var sinCache:Object = {};

        // 将点绕原点旋转
        function rotatePoint(origin:Point, p:Point, degrees:Number, radian:Number):void {
            if (isNaN(radian) || radian == 0) {
                radian = degrees * Math.PI / 180;
            }

            var cos:Number = cosCache[degrees] ? cosCache[degrees] : Math.cos(radian);
            var sin:Number = sinCache[degrees] ? sinCache[degrees] : Math.sin(radian);

            cosCache[degrees] = cos;
            sinCache[degrees] = sin;

            var x0:Number = (p.x - origin.x) * cos - (p.y - origin.y) * sin;
            var y0:Number = (p.y - origin.y) * cos + (p.x - origin.x) * sin;

            p.x = x0 + origin.x;
            p.y = y0 + origin.y;
        }

        // 获取矩形四角点（可旋转）
        function getRectEachPoint(dis:Rectangle, origin:Point, angle:int, radian:Number = 0):Array {
            var fourPointArr:Array = [];

            var tx:int = int(dis.x - origin.x);
            var ty:int = int(dis.y - origin.y);
            var tw:int = int(tx + dis.width);
            var th:int = int(ty + dis.height);

            fourPointArr[0] = new Point(tx, th);
            fourPointArr[1] = new Point(tx, ty);
            fourPointArr[2] = new Point(tw, ty);
            fourPointArr[3] = new Point(tw, th);

            var ro:Point = new Point(dis.x, dis.y);
            for (var i:int = 0; i < 4; ++i) {
                rotatePoint(ro, fourPointArr[i], angle, radian);
            }

            return fourPointArr;
        }

        var projPoint:Point = new Point();

        function getProjectPoint(axis:Point, p:Point):Point {
            var pPlus:int    = int(p.x * axis.x + p.y * axis.y);
            var axis2x:int   = int(axis.x * axis.x);
            var axis2y:int   = int(axis.y * axis.y);
            var axisPlus:int = axis2x + axis2y;

            projPoint.x = pPlus / axisPlus * axis.x;
            projPoint.y = pPlus / axisPlus * axis.y;

            return projPoint;
        }

        function getScalarValue(arr:Array, axis:Point):Array {
            var minMaxArr:Array = [];
            var tempArray:Array = [];
            for (var i:int = 0; i < 4; ++i) {
                var pp:Point = getProjectPoint(axis, arr[i]);
                tempArray[i] = pp.x * axis.x + pp.y * axis.y;
            }
            tempArray.sort(Array.NUMERIC);
            minMaxArr[0] = tempArray[0];
            minMaxArr[1] = tempArray[3];
            tempArray    = null;

            return minMaxArr;
        }

        function projectOverlap(axis:Point, rectArr1:Array, rectArr2:Array):Boolean {
            var rect1MinMax:Array = getScalarValue(rectArr1, axis);
            var rect2MinMax:Array = getScalarValue(rectArr2, axis);

            return rect2MinMax[0] > rect1MinMax[1] || rect2MinMax[1] < rect1MinMax[0];
        }

        function maybeCollide(p00:Point, p01:Point, p10:Point, p11:Point):Boolean {
            var r1:int         = getTwoPointDistance(p00, p01);
            var r2:int         = getTwoPointDistance(p10, p11);
            var abDistance:int = getTwoPointDistance(p00, p10);

            return abDistance <= r1 + r2;
        }

        function getTwoPointDistance(p1:Point, p2:Point):int {
            var ax:int = int(p1.x - p2.x);
            var ay:int = int(p1.y - p2.y);

            return Math.sqrt(ax * ax + ay * ay);
        }

        if (isNaN(obj1.x + obj1.y + obj1.width + obj1.height)) {
            throw new Error('在obj1中未找到 x/y/width/height');
        }
        if (isNaN(obj2.x + obj2.y + obj2.width + obj2.height)) {
            throw new Error('在obj2中未找到 x/y/width/height');
        }

        var rect1:Rectangle = new Rectangle(obj1.x, obj1.y, obj1.width, obj1.height);
        var rotation1:int   = int(obj1.rotation);
        var scaleX1:Number  = obj1.scaleX != undefined ? obj1.scaleX : 1;
        var origin1:Point   = new Point(
                obj1.originX != undefined ? obj1.originX : 0,
                obj1.originY != undefined ? obj1.originY : 0
        );
        var radian1:Number  = obj1.radian;

        var rect2:Rectangle = new Rectangle(obj2.x, obj2.y, obj2.width, obj2.height);
        var rotation2:int   = int(obj2.rotation);
        var scaleX2:Number  = obj2.scaleX != undefined ? obj2.scaleX : 1;
        var origin2:Point   = new Point(
                obj2.originX != undefined ? obj2.originX : 0,
                obj2.originY != undefined ? obj2.originY : 0
        );
        var radian2:Number  = obj2.radian;

        if (scaleX1 < 0) {
            origin1.x = rect1.width - origin1.x;
            rect1.x   = rect1.x - rect1.width + obj1.originX + origin1.x;
        }

        if (scaleX2 < 0) {
            origin2.x = rect2.width - origin2.x;
            rect2.x   = rect2.x - rect2.width + obj2.originX + origin2.x;
        }

        var arr1:Array = getRectEachPoint(rect1, origin1, rotation1, radian1);
        var arr2:Array = getRectEachPoint(rect2, origin2, rotation2, radian2);

        if (!maybeCollide(origin1, arr1[0], origin2, arr2[0])) {
            return false;
        }

        var axisArr:Array = [
            new Point(arr1[2].x - arr1[1].x, arr1[2].y - arr1[1].y),
            new Point(arr1[2].x - arr1[3].x, arr1[2].y - arr1[3].y),
            new Point(arr2[1].x - arr2[0].x, arr2[1].y - arr2[0].y),
            new Point(arr2[1].x - arr2[2].x, arr2[1].y - arr2[2].y)
        ];

        for (var i:int = 0; i < 4; ++i) {
            if (projectOverlap(axisArr[i], arr1, arr2)) {
                return false;
            }
        }

        return true;
    }

    /**
     * 判断显示对象是否位于容器在指定全局点下的最顶层。
     * @param child 待测显示对象。
     * @param container 命中检测容器；默认 <code>child.stage</code>。
     * @param globalPoint 全局检测点；默认舞台中心。
     * @return 是否为该点下最顶层（容器则含其子项）。
     * @example
     * <listing version="3.0">
     * if (KyoDisplayUtils.isInTop(panel)) { ... }
     * </listing>
     */
    public static function isInTop(
            child:DisplayObject, container:DisplayObjectContainer = null, globalPoint:Point = null):Boolean {
        if (!container) {
            container = child.stage;
        }
        if (!globalPoint) {
            globalPoint = new Point(1, 1);
            try {
                globalPoint.x = container.stage.stageWidth / 2;
                globalPoint.y = container.stage.stageHeight / 2;
            }
            catch (e:Error) {
            }
        }

        var arr:Array = container.getObjectsUnderPoint(globalPoint);
        if (arr && arr.length > 0) {
            var top:DisplayObject = arr.pop();
            if (child is DisplayObjectContainer) {
                var dc:DisplayObjectContainer = child as DisplayObjectContainer;

                return dc.contains(top);
            }

            return top == child;
        }

        return false;
    }

    /**
     * 将物理厘米换算为屏幕像素（按 <code>Capabilities.screenDPI</code>）。
     * @param cm 厘米。
     * @return 像素。
     * @example
     * <listing version="3.0">
     * var px:Number = KyoDisplayUtils.cm2pixel(1);
     * </listing>
     */
    public static function cm2pixel(cm:Number):Number {
        return (cm * Capabilities.screenDPI) / 2.54;
    }

    /**
     * 将厘米坐标换算为像素点。
     * @param cmX X 厘米。
     * @param cmY Y 厘米。
     * @return 像素坐标。
     * @example
     * <listing version="3.0">
     * var p:Point = KyoDisplayUtils.getPointByCM(1, 2);
     * </listing>
     */
    public static function getPointByCM(cmX:Number = 0, cmY:Number = 0):Point {
        return new Point(cm2pixel(cmX), cm2pixel(cmY));
    }

    /**
     * 移除 Sprite 全部子显示对象（委托 <code>removeAllChildren</code>）。
     * @param sp 容器。
     * @example
     * <listing version="3.0">
     * KyoDisplayUtils.removeAllChildrenFromSprite(box);
     * </listing>
     * @see #removeAllChildren()
     */
    public static function removeAllChildrenFromSprite(sp:Sprite):void {
        removeAllChildren(sp);
    }

    /**
     * 获取 MC 的所有帧的绘制位图。
     * @param mc 目标显示对象（<code>MovieClip</code> 则逐帧）。
     * @return <code>BitmapData</code> 数组。
     * @example
     * <listing version="3.0">
     * var frames:Array = KyoDisplayUtils.getBitmapDatasByMC(mc);
     * </listing>
     */
    public static function getBitmapDatasByMC(mc:DisplayObject):Array {
        var a:Array = [];
        var bd:BitmapData;
        if (mc is MovieClip) {
            var mmc:MovieClip = mc as MovieClip;
            for (var i:int = 1; i <= mmc.totalFrames; i++) {
                mmc.gotoAndStop(i);
                bd = new BitmapData(mmc.width, mmc.height, true, 0);
                bd.draw(mmc);
                a.push(bd);
            }
        }
        else {
            bd = new BitmapData(mc.width, mc.height, true, 0);
            bd.draw(mc);
            a.push(bd);
        }

        return a;
    }

    /**
     * 绘制显示对象为位图。
     * @param d 源显示对象。
     * @param fixPosition 根据注册点位置调节。
     * @param transparent 是否透明底。
     * @param fillColor 填充色。
     * @param colorTransform 可选颜色变换。
     * @return 位图；无效尺寸时为 <code>null</code>。
     * @example
     * <listing version="3.0">
     * var bp:Bitmap = KyoDisplayUtils.drawDisplay(mc);
     * </listing>
     */
    public static function drawDisplay(
            d:DisplayObject, fixPosition:Boolean = true, transparent:Boolean = true, fillColor:uint = KyoColor.BLACK,
            colorTransform:ColorTransform                                                           = null
    ):Bitmap {
        if (!d || d.width <= 0 || d.height <= 0) {
            return null;
        }

        var bp:Bitmap = new Bitmap(new BitmapData(d.width, d.height, transparent, fillColor));
        var matrix:Matrix;
        if (fixPosition) {
            var bds:Rectangle = d.getBounds(d);
            matrix            = new Matrix(1, 0, 0, 1, -bds.x, -bds.y);
        }
        bp.bitmapData.draw(d, matrix, colorTransform);

        return bp;
    }

    /**
     * 绘制显示对象并应用滤镜，返回位图数据。
     * @param d 源显示对象。
     * @param filter 滤镜。
     * @param fixPosition 根据注册点位置调节。
     * @param filterOffset 绘制大小调节。
     * @return 处理后的 <code>BitmapData</code>。
     * @example
     * <listing version="3.0">
     * var bd:BitmapData = KyoDisplayUtils.drawBitmapFilter(mc, blur);
     * </listing>
     */
    public static function drawBitmapFilter(
            d:DisplayObject, filter:BitmapFilter, fixPosition:Boolean = true, filterOffset:Point = null):BitmapData {
        var bpd:BitmapData = new BitmapData(d.width, d.height, true, 0);

        var matrix:Matrix;
        if (fixPosition) {
            var bds:Rectangle = d.getBounds(d);
            matrix            = new Matrix(1, 0, 0, 1, -bds.x, -bds.y);
        }

        bpd.draw(d, matrix);

        var rect:Rectangle = new Rectangle(0, 0, d.width, d.height);

        if (filterOffset) {
            rect.x -= filterOffset.x;
            rect.y -= filterOffset.y;
            rect.width += filterOffset.x * 2;
            rect.height += filterOffset.y * 2;
        }

        var bpd2:BitmapData = new BitmapData(rect.width, rect.height, true, 0);
        bpd2.applyFilter(bpd, rect, new Point(), filter);

        bpd.dispose();

        return bpd2;
    }

    /**
     * 绘制图像倒影。
     * @param d 源显示对象。
     * @param height 倒影高度。
     * @param alpha 透明度。
     * @return 倒影位图。
     * @example
     * <listing version="3.0">
     * var shadow:Bitmap = KyoDisplayUtils.drawInverted(mc, 40);
     * </listing>
     */
    public static function drawInverted(d:DisplayObject, height:Number, alpha:Number = 0.3):Bitmap {
        var bp:Bitmap     = new Bitmap(new BitmapData(d.width, height, true, 0));
        var matrix:Matrix = new Matrix();
        matrix.ty         = -height;
        bp.bitmapData.draw(d, matrix);
        bp.scaleY = -1;
        bp.y      = d.height + height / 1.7;
        bp.alpha  = alpha;

        return bp;
    }

    /**
     * 根据帧标签翻译 MC。
     * @param mc 目标 MovieClip。
     * @param label 帧标签。
     * @example
     * <listing version="3.0">
     * KyoDisplayUtils.translateMC(mc, 'idle');
     * </listing>
     */
    public static function translateMC(mc:MovieClip, label:String):void {
        if (label == null) {
            return;
        }
        for each(var o:Object in mc.currentLabels) {
            if (o.name == label) {
                mc.gotoAndStop(label);
                return;
            }
        }
        for (var i:int; i < mc.numChildren; i++) {
            var d:DisplayObject = mc.getChildAt(i);
            if (d is MovieClip) {
                translateMC(d as MovieClip, label);
            }
        }
    }

    /**
     * 按阈值将位图某色设为透明。
     * @param source <code>Bitmap</code> 或 <code>BitmapData</code>。
     * @param arg1 省略则取 (0,0) 像素；为颜色值；或与 arg2 组成采样坐标 x。
     * @param arg2 采样坐标 y（当 arg1 为 x 时）。
     * @return 处理后的位图数据。
     * @example
     * <listing version="3.0">
     * var bd:BitmapData = KyoDisplayUtils.transparent(bmp);
     * </listing>
     */
    public static function transparent(source:*, arg1:* = null, arg2:* = null):BitmapData {
        var threshold:uint;
        var s:BitmapData = source is Bitmap ? source.bitmapData : source;
        if (arg1 == null) {
            threshold = s.getPixel(0, 0);
        }
        else {
            if (arg2 == null) {
                threshold = arg1;
            }
            else {
                threshold = s.getPixel(arg1, arg2);
            }
        }
        var rect:Rectangle    = new Rectangle(0, 0, s.width, s.height);
        var origin:Point      = new Point(0, 0);
        var result:BitmapData = new BitmapData(s.width, s.height, true);
        result.copyPixels(s, rect, origin);
        result.threshold(s, rect, origin, '==', threshold, 0, 0xF0F0F0, true);

        return result;
    }

    /**
     * 获取显示对象相对目标祖先容器的坐标。
     * @param d 要移动的显示对象。
     * @param to 目标显示对象（祖先）。
     * @return 相对坐标；若 <code>to</code> 非祖先则返回累加坐标并 <code>trace</code> 警告。
     * @example
     * <listing version="3.0">
     * var p:Point = KyoDisplayUtils.getToChildPoint(child, root);
     * </listing>
     */
    public static function getToChildPoint(d:DisplayObject, to:DisplayObjectContainer):Point {
        var pt:Point                 = new Point(d.x, d.y);
        var p:DisplayObjectContainer = d.parent;
        while (p != null) {
            pt.x += p.x;
            pt.y += p.y;
            if (p == to) {
                return pt;
            }
            p = p.parent;
        }
        trace(to, 'is not', d, '\'s parent!');

        return pt;
    }

    /**
     * 将显示对象移动到另一容器内。
     * @param d 移动的显示对象。
     * @param to 目标容器。
     * @param fixParentPoint 自动调整坐标（仅当目标为祖先时有效）。
     * @example
     * <listing version="3.0">
     * KyoDisplayUtils.moveDisplay(child, box);
     * </listing>
     */
    public static function moveDisplay(d:DisplayObject, to:DisplayObjectContainer, fixParentPoint:Boolean = true):void {
        if (fixParentPoint) {
            var p:Point = getToChildPoint(d, to);
            d.x         = p.x;
            d.y         = p.y;
        }
        to.addChild(d);
    }

    /**
     * 移除容器全部子对象，可对每个子项回调。
     * @param d 容器。
     * @param itemCallFunction 每个被移除子对象的回调；可省略。
     * @example
     * <listing version="3.0">
     * KyoDisplayUtils.removeAllChildren(box);
     * </listing>
     */
    public static function removeAllChildren(d:DisplayObjectContainer, itemCallFunction:Function = null):void {
        while (d.numChildren) {
            var dd:DisplayObject = d.removeChildAt(0);
            if (itemCallFunction != null) {
                itemCallFunction(dd);
            }
        }
    }

    /**
     * 按名称移除子对象。
     * @param d 容器。
     * @param name 子对象名。
     * @example
     * <listing version="3.0">
     * KyoDisplayUtils.removeChildByName(box, 'tip');
     * </listing>
     */
    public static function removeChildByName(d:DisplayObjectContainer, name:String):void {
        var o:DisplayObject = d.getChildByName(name);
        if (o) {
            d.removeChild(o);
        }
    }

    /**
     * 在 MovieClip 指定帧加入脚本。
     * @param mc 目标 MovieClip。
     * @param script 帧脚本。
     * @param frame 帧索引（0 基，传给 <code>addFrameScript</code>）；-1 时为最后一帧。
     * @example
     * <listing version="3.0">
     * KyoDisplayUtils.addFrameScript(mc, onEnd);
     * </listing>
     */
    public static function addFrameScript(mc:MovieClip, script:Function, frame:int = -1):void {
        var f:uint = frame == -1 ? mc.totalFrames - 1 : uint(frame);
        mc.addFrameScript(f, script);
    }

    /**
     * 将显示对象灰度化，或还原并移除灰度滤镜。
     * @param mc 目标显示对象。
     * @param restore 为 <code>true</code> 时移除 <code>ColorMatrixFilter</code> 并还原其余滤镜。
     * @example
     * <listing version="3.0">
     * KyoDisplayUtils.grayMC(mc);
     * </listing>
     */
    public static function grayMC(mc:DisplayObject, restore:Boolean = false):void {
        if (!mc) {
            return;
        }

        if (restore) {
            var fs:Array = mc.filters.concat();
            mc.filters   = null;
            for (var i:int = fs.length - 1; i >= 0; i--) {
                if (fs[i] is ColorMatrixFilter) {
                    fs.splice(i, 1);
                }
            }
            mc.filters = fs;

            return;
        }

        var mtx:Array              = [];
        mtx                        = mtx.concat([0.3086, 0.6094, 0.082, 0, 0]); // red
        mtx                        = mtx.concat([0.3086, 0.6094, 0.082, 0, 0]); // green
        mtx                        = mtx.concat([0.3086, 0.6094, 0.082, 0, 0]); // blue
        mtx                        = mtx.concat([0, 0, 0, 1, 0]); // alpha
        var gray:ColorMatrixFilter = new ColorMatrixFilter(mtx);
        mc.filters                 = [gray];
    }

    /**
     * 设置 Sprite 音量。
     * @param mc 目标。
     * @param volume 0~1。
     * @example
     * <listing version="3.0">
     * KyoDisplayUtils.setMcVolume(root, 0.5);
     * </listing>
     */
    public static function setMcVolume(mc:Sprite, volume:Number):void {
        if (!mc) {
            return;
        }
        var st:SoundTransform = mc.soundTransform;
        if (st) {
            st.volume         = volume;
            mc.soundTransform = st;
        }
    }

    /**
     * 克隆 ColorTransform（不含 color 属性赋值）。
     * @param ct 源。
     * @return 新实例。
     * @example
     * <listing version="3.0">
     * var ct2:ColorTransform = KyoDisplayUtils.cloneColorTransform(ct);
     * </listing>
     */
    public static function cloneColorTransform(ct:ColorTransform):ColorTransform {
        var newCt:ColorTransform = new ColorTransform();

        newCt.alphaMultiplier = ct.alphaMultiplier;
        newCt.alphaOffset     = ct.alphaOffset;

        newCt.blueMultiplier = ct.blueMultiplier;
        newCt.blueOffset     = ct.blueOffset;

        newCt.greenMultiplier = ct.greenMultiplier;
        newCt.greenOffset     = ct.greenOffset;

        newCt.redMultiplier = ct.redMultiplier;
        newCt.redOffset     = ct.redOffset;

        return newCt;
    }

    /**
     * 影片剪辑是否具有指定名称帧标签。
     * @param mc 影片剪辑。
     * @param label 帧标签名。
     * @return 是否存在。
     * @example
     * <listing version="3.0">
     * if (KyoDisplayUtils.hasFrameLabel(mc, 'loop')) { ... }
     * </listing>
     */
    public static function hasFrameLabel(mc:MovieClip, label:String):Boolean {
        var labels:Array = mc.currentLabels;

        for each(var i:FrameLabel in labels) {
            if (i.name == label) {
                return true;
            }
        }

        return false;
    }

    /**
     * 设置显示对象色相滤镜（-180 – 180）；为 0 时清除 filters。
     * @param display 目标。
     * @param hue 色相值。
     * @example
     * <listing version="3.0">
     * KyoDisplayUtils.setHue(mc, 30);
     * </listing>
     */
    public static function setHue(display:DisplayObject, hue:Number = 0):void {
        if (hue == 0) {
            display.filters = null;
            return;
        }

        var filter:ColorMatrixFilter = createHueFilter(hue);
        display.filters              = [filter];
    }

    /**
     * 递归停止指定影片剪辑的子 MovieClip 播放（不含自身 stop）。
     * @param mc 根影片剪辑。
     * @example
     * <listing version="3.0">
     * KyoDisplayUtils.stopAllMovieClips(rootMc);
     * </listing>
     */
    public static function stopAllMovieClips(mc:MovieClip):void {
        for (var i:int = 0; i < mc.numChildren; i++) {
            var d:DisplayObject = mc.getChildAt(i);

            if (d && d is MovieClip) {
                var m:MovieClip = d as MovieClip;

                m.stop();
                stopAllMovieClips(m);
            }
        }
    }

    /** @private 创建色相 ColorMatrixFilter。 */
    private static function createHueFilter(n:Number):ColorMatrixFilter {
        const p1:Number = Math.cos(n * Math.PI / 180);
        const p2:Number = Math.sin(n * Math.PI / 180);
        const p4:Number = 0.213;
        const p5:Number = 0.715;
        const p6:Number = 0.072;

        const matrix:Array = [
            p4 + p1 * (1 - p4) + p2 * (0 - p4),
            p5 + p1 * (0 - p5) + p2 * (0 - p5),
            p6 + p1 * (0 - p6) + p2 * (1 - p6),
            0,
            0,
            p4 + p1 * (0 - p4) + p2 * 0.143,
            p5 + p1 * (1 - p5) + p2 * 0.14,
            p6 + p1 * (0 - p6) + p2 * -0.283,
            0,
            0,
            p4 + p1 * (0 - p4) + p2 * (0 - (1 - p4)),
            p5 + p1 * (0 - p5) + p2 * p5,
            p6 + p1 * (1 - p6) + p2 * p6,
            0,
            0,
            0,
            0,
            0,
            1,
            0
        ];

        return new ColorMatrixFilter(matrix);
    }

}
}
