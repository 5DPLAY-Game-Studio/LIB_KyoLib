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
import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.events.Event;
import flash.geom.Point;
import flash.geom.Rectangle;

import net.play5d.kyo.utils.KyoArrayUtils;
import net.play5d.kyo.utils.KyoDisplayUtils;
import net.play5d.kyo.utils.KyoMath;

/**
 * 表格排行样式瓦片列表：按横竖排数分页排列子项，支持遮罩滚动与滚动条联动。
 *
 * <p>调用 <code>#update()</code> 或修改 <code>#page</code> 后重新布局，并派发 <code>Event.CHANGE</code>。</p>
 *
 * @see KyoScrollList
 * @see #list()
 * @see #update()
 * @author kyo
 */
public class KyoTileList extends Sprite {
    /**
     * @param displays 显示对象数组，可为 <code>null</code>。
     * @param hrow 每行最大个数，默认不限。
     * @param vrow 每列最大个数，默认 1。
     * @example
     * <listing version="3.0">
     * var list:KyoTileList = new KyoTileList([a, b, c], 3, 2);
     * </listing>
     */
    [ArrayElementType('flash.display.DisplayObject')]
    public function KyoTileList(displays:Array = null, hrow:int = int.MAX_VALUE, vrow:int = 1) {
        _hRow = hrow;
        _vRow = vrow;
        setDisplays(displays);
    }

    /**
     * 子项之间的水平与垂直间距。
     * @default (5, 5)
     */
    public var gap:Point          = new Point(5, 5);
    /**
     * 统一单元宽高；首项尺寸为 0 时由首个有效子项填充。
     */
    public var unitySize:Point    = new Point();
    /**
     * 换行时插入的横线元件类，未设置则不绘制。
     */
    public var HLine:Class;
    /**
     * 换列时插入的竖线元件类，未设置则不绘制。
     */
    public var VLine:Class;
    /**
     * 显示编号，<code>-1</code> 表示不显示。
     * @default -1
     */
    public var showNum:int        = -1;
    /**
     * 当前管理的显示对象数组。
     */
    [ArrayElementType('flash.display.DisplayObject')]
    public var displays:Array;
    /**
     * 布局起始坐标。
     */
    public var startPos:Point     = new Point();
    /**
     * 关联滚动条；内容超出遮罩时自动启用。
     */
    public var scrollBar:IKyoScrollBar;
    /**
     * 为 <code>true</code> 时各行使用 <code>#unitySize</code> 计步，忽略各子项实际尺寸。
     * @default false
     */
    public var lockSize:Boolean   = false;
    /**
     * 为 <code>true</code> 时水平滚动比例含 <code>#unitySize</code> 偏移。
     * @default true
     */
    public var scrollHadd:Boolean = true;
    /**
     * 最近一次布局产生的垂直行数（只读结果缓存）。
     */
    public var rowV:int;
    /**
     * 布局内容总宽度。
     */
    protected var _width:Number   = 0;
    /**
     * 布局内容总高度。
     */
    protected var _height:Number  = 0;
    /** @private 每行最大个数 */
    private var _hRow:int;
    /** @private 每列最大个数 */
    private var _vRow:int;
    /** @private 当前页码（从 1 起） */
    private var _page:int         = 1;
    /** @private 每页项数 */
    private var _perPage:int;
    /** @private 总页数 */
    private var _totalPage:int    = 1;
    /** @private 遮罩可视尺寸 */
    private var _maskSize:Point;
    /** @private 滚动比例位置（0–1） */
    private var _scrollPos:Point;

    /**
     * 当前页码（1 至 <code>#totalPage</code>）。
     * @return 页码。
     * @default 1
     */
    public function get page():int {
        return _page;
    }

    /** @private */
    public function set page(value:int):void {
        if (_page == value) {
            return;
        }
        _page = value;
        update();
    }

    /**
     * 每页可容纳的子项数量（<code>_hRow * _vRow</code>）。
     * @return 每页项数。
     */
    public function get perPage():int {
        return _perPage;
    }

    /**
     * 根据子项总数与分页设置计算的总页数。
     * @return 总页数。
     * @default 1
     */
    public function get totalPage():int {
        return _totalPage;
    }

    /**
     * 遮罩可视区域尺寸。
     * @return 遮罩 <code>Point</code>。
     */
    public function get maskSize():Point {
        return _maskSize;
    }

    /** @private */
    public function set maskSize(value:Point):void {
        _maskSize  = value;
        scrollRect = new Rectangle(0, 0, _maskSize.x, _maskSize.y);
    }

    /**
     * 滚动比例位置，<code>x</code>/<code>y</code> 均为 0–1。
     * @return 滚动比例。
     */
    public function get scrollPos():Point {
        return _scrollPos;
    }

    /** @private */
    public function set scrollPos(value:Point):void {
        _scrollPos = value;

        var rect:Rectangle = new Rectangle(0, 0, _maskSize.x, _maskSize.y);

        if (scrollHadd) {
            rect.x = _scrollPos.x * (_width + unitySize.x - _maskSize.x);
            rect.y = _scrollPos.y * (_height + unitySize.y - _maskSize.y);
        }
        else {
            rect.x = _scrollPos.x * (_width - _maskSize.x);
            rect.y = _scrollPos.y * (_height - _maskSize.y);
        }

        scrollRect = rect;
    }

    /**
     * 子项数组长度。
     * @return 项数。
     */
    public function get length():uint {
        return displays.length;
    }

    /**
     * 当前垂直滚动像素偏移（<code>scrollRect.y</code>）。
     * @return 垂直偏移。
     */
    public function get scrollV():Number {
        return scrollRect.y;
    }

    /** @private */
    public function set scrollV(v:Number):void {
        var rect:Rectangle = new Rectangle(0, 0, _maskSize.x, _maskSize.y);
        rect.y             = v;
        scrollRect         = rect;
    }

    /**
     * 当前水平滚动像素偏移（<code>scrollRect.x</code>）。
     * @return 水平偏移。
     */
    public function get scrollH():Number {
        return scrollRect.x;
    }

    /** @private */
    public function set scrollH(v:Number):void {
        var rect:Rectangle = new Rectangle(0, 0, _maskSize.x, _maskSize.y);
        rect.x             = v;
        scrollRect         = rect;
    }

    /**
     * 返回子项在 <code>#displays</code> 中的索引。
     * @param child 子显示对象。
     * @return 索引，不存在时为 <code>-1</code>。
     * @example
     * <listing version="3.0">
     * var i:int = list.getChildIndex(icon);
     * </listing>
     */
    public override function getChildIndex(child:DisplayObject):int {
        return displays.indexOf(child);
    }

    /**
     * 从列表与显示树中移除子项并重新布局。
     * @param child 待移除对象。
     * @return 被移除的对象。
     * @example
     * <listing version="3.0">
     * list.removeChild(icon);
     * </listing>
     */
    public override function removeChild(child:DisplayObject):DisplayObject {
        KyoArrayUtils.removeItem(displays, child);
        var d:DisplayObject = super.removeChild(child);

        update();
        return d;
    }

    /**
     * 替换全部子项并重新布局。
     * @param v 新的显示对象数组。
     * @example
     * <listing version="3.0">
     * list.setDisplays([icon1, icon2]);
     * </listing>
     */
    [ArrayElementType('flash.display.DisplayObject')]
    public function setDisplays(v:Array):void {
        removeAllChildren();
        displays = v;
        if (displays && displays.length > 0) {
            update();
        }
    }

    /**
     * 追加一个子项并重新布局。
     * @param d 显示对象。
     * @example
     * <listing version="3.0">
     * list.addDisplay(new Sprite());
     * </listing>
     */
    public function addDisplay(d:DisplayObject):void {
        displays ||= [];
        displays.push(d);
        update();
    }

    /**
     * 清空子项数组并移除所有显示子对象。
     * @example
     * <listing version="3.0">
     * list.removeAllChildren();
     * </listing>
     */
    public function removeAllChildren():void {
        displays = [];
        KyoDisplayUtils.removeAllChildren(this);
    }

    /**
     * 按引用移除子项。
     * @param d 待移除对象。
     * @param updateNow 是否立即重新布局，默认 <code>true</code>。
     * @example
     * <listing version="3.0">
     * list.removeDisplay(icon);
     * </listing>
     */
    public function removeDisplay(d:DisplayObject, updateNow:Boolean = true):void {
        var id:int = displays.indexOf(d);
        if (id == -1) {
            return;
        }
        removeDisplayAt(id, updateNow);
    }

    /**
     * 按索引移除子项。
     * @param id 数组索引。
     * @param updateNow 是否立即重新布局，默认 <code>true</code>。
     * @example
     * <listing version="3.0">
     * list.removeDisplayAt(0);
     * </listing>
     */
    public function removeDisplayAt(id:int, updateNow:Boolean = true):void {
        displays.splice(id, 1);
        if (updateNow) {
            update();
        }
    }

    /**
     * 为每个非空子项注册同一事件监听。
     * @param event 事件类型。
     * @param handler 监听函数。
     * @example
     * <listing version="3.0">
     * list.addItemsListener(MouseEvent.CLICK, onItemClick);
     * </listing>
     */
    public function addItemsListener(event:String, handler:Function):void {
        for each(var d:DisplayObject in displays) {
            if (d == null) {
                continue;
            }
            d.addEventListener(event, handler);
        }
    }

    /**
     * 从每个非空子项移除同一事件监听。
     * @param event 事件类型。
     * @param handler 监听函数。
     * @example
     * <listing version="3.0">
     * list.removeItemsListener(MouseEvent.CLICK, onItemClick);
     * </listing>
     */
    public function removeItemsListener(event:String, handler:Function):void {
        for each(var d:DisplayObject in displays) {
            if (d == null) {
                continue;
            }
            d.removeEventListener(event, handler);
        }
    }

    /**
     * 对每个非空子项调用同名方法并传入相同参数。
     * @param fun 方法名字符串。
     * @param params 可变参数列表。
     * @example
     * <listing version="3.0">
     * list.callAll('gotoAndStop', 1);
     * </listing>
     */
    public function callAll(fun:String, ...params):void {
        for each (var d:DisplayObject in displays) {
            if (d == null) {
                continue;
            }

            var f:Function = d[fun];
            f.apply(null, params);
        }
    }

    /**
     * 在指定索引插入子项并重新布局。
     * @param d 待插入对象。
     * @param index 插入位置。
     * @example
     * <listing version="3.0">
     * list.appendChild(icon, 0);
     * </listing>
     */
    public function appendChild(d:Object, index:int):void {
        KyoArrayUtils.pushAt(displays, d, index);
        update();
    }

    /**
     * 重算分页、布局子项、同步滚动条，并派发 <code>Event.CHANGE</code>。
     * @example
     * <listing version="3.0">
     * list.page = 2;
     * list.update();
     * </listing>
     */
    public function update():void {
        if (_hRow < int.MAX_VALUE && _vRow < int.MAX_VALUE) {
            _perPage   = _hRow * _vRow;
            _totalPage = Math.ceil(displays.length / _perPage);
        }
        _page = KyoMath.fixRange(_page, 1, _totalPage);

        list(_hRow, _vRow);
        if (scrollBar) {
            if (_width > maskSize.x || _height > maskSize.y) {
                scrollBar.enabled = true;
                if (!scrollBar.hasEventListener(KyoUIEvent.UPDATE)) {
                    scrollBar.addEventListener(KyoUIEvent.UPDATE, srollUpdate);
                }
            }
            else {
                scrollBar.enabled = false;
                scrollPos         = new Point();
                scrollBar.update(0);
            }
        }

        dispatchEvent(new Event(Event.CHANGE));
    }

    /**
     * 按给定行列数排列当前页子项并更新 <code>#_width</code>/<code>#_height</code>。
     *
     * <p>可选绘制 <code>#HLine</code>/<code>#VLine</code> 分隔线。</p>
     *
     * @param h 每行个数。
     * @param v 每列个数。
     * @example
     * <listing version="3.0">
     * list.list(4, 2);
     * </listing>
     */
    public function list(h:int, v:int):void {
        KyoDisplayUtils.removeAllChildren(this);

        var p:Point = startPos.clone();
        var s:int   = (_page - 1) * _perPage;
        var e:int;
        if (h >= int.MAX_VALUE || v >= int.MAX_VALUE) {
            e = int.MAX_VALUE;
        }
        else {
            e = s + h * v;
        }

        if (e > displays.length) {
            e = displays.length;
        }
        rowV = 0;
        var firsted:Boolean;
        var overh:Boolean;
        for (var i:int = s; i < e; i++) {
            var d:DisplayObject = displays[i];
            if (!d) {
                continue;
            }

            if (!firsted) {
                firsted = true;
                if (unitySize.x == 0) {
                    unitySize.x = d.width;
                }
                if (unitySize.y == 0) {
                    unitySize.y = d.height;
                }
                _width  = unitySize.x;
                _height = unitySize.y;
            }

            d.x = p.x;
            d.y = p.y;
            if ((i + 1) % h == 0) {
                overh         = true;
                p.x           = startPos.x;
                var yy:Number = lockSize ? unitySize.y : d.height;
                p.y += yy + gap.y;
                if (VLine) {
                    var vl:DisplayObject = new VLine();
                    vl.x                 = 0;
                    vl.y                 = p.y - gap.y / 2;
                    addChild(vl);
                }
                if (_height < p.y) {
                    _height = p.y;
                }
            }
            else {
                if (overh) {
                    rowV++;
                    overh = false;
                }
                var xx:Number = lockSize ? unitySize.x : d.width;
                p.x += xx + gap.x;
                if (_width < p.x) {
                    _width = p.x;
                }
            }
            addChild(d);
        }

        if (h % _hRow != 0) {
            xx = lockSize ? unitySize.x : d.width;
            _width += xx;
        }
        if (rowV % _vRow != 0) {
            yy = lockSize ? unitySize.y : d.height;
            _height += yy;
        }

    }

    /**
     * 在容器宽度内水平居中列表内容。
     * @param ctWidth 容器宽度。
     * @example
     * <listing version="3.0">
     * list.alignCenterH(800);
     * </listing>
     */
    public function alignCenterH(ctWidth:Number):void {
        if (!displays || displays.length < 1) {
            return;
        }
        var w:Number;
        if (lockSize && unitySize) {
            var hw:int = Math.min(displays.length, _hRow);
            w          = (unitySize.x + gap.x) * (hw - 1) + unitySize.x;
        }
        else {
            w = _width;
        }
        x = (ctWidth - w) / 2;
    }

    /**
     * 将当前滚动比例同步到关联滚动条。
     */
    protected function updateScrollBar():void {
        if (scrollBar) {
            scrollBar.update(_scrollPos.y);
        }
    }

    /** @private 滚动条拖拽回调，更新 <code>#scrollPos</code>。 */
    private function srollUpdate(e:KyoUIEvent):void {
        var pos:Point = e.params as Point;
        scrollPos     = pos;
    }

}
}
