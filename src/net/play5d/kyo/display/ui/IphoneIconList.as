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

import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.display.Stage;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.geom.Rectangle;

import net.play5d.kyo.utils.KyoColor;

/**
 * 翻页完成时分派。
 * @eventType IphoneIconListEvent.PAGE_CHANGE
 */
[Event(name='PAGE_CHANGE', type='net.play5d.kyo.display.ui.IphoneIconListEvent')]
/**
 * iPhone 风格分页图标列表：横向滑动翻页，每页为 <code>KyoTileList</code>。
 *
 * @see IphoneIconListEvent
 * @see IphoneIconListDoc
 * @see IPhoneBtn
 * @see #setDisplay()
 * @see #goPage()
 */
public class IphoneIconList extends Sprite {
    /**
     * @param touchSize 单页触摸 / 可视区域尺寸。
     * @param unitSize 单个图标单元尺寸；参与自动计算间距。
     * @param perPage 每页图标数，默认 16。
     * @param hRow 每行图标数，默认 4。
     */
    public function IphoneIconList(touchSize:Point, unitSize:Point = null, perPage:int = 16, hRow:int = 4) {
        this.touchSize = touchSize;
        _unitSize      = unitSize;
        this.perPage   = perPage;
        this.hRow      = hRow;
    }

    /**
     * 当前页（从 1 起）。
     * @default 0
     */
    public var curPage:int;
    /**
     * 总页数。
     * @default 0
     */
    public var totalPage:int;
    /**
     * 每页图标数。
     */
    public var perPage:int;
    /**
     * 内容水平偏移（与 <code>scrollRect</code> 联动；Tween 目标属性）。
     * @default 0
     */
    public var contentX:Number      = 0;
    /**
     * 每行图标数。
     * @default 4
     */
    public var hRow:int             = 4;
    /**
     * 单页可视尺寸。
     */
    public var touchSize:Point;
    /**
     * 是否响应滑动翻页。
     * @default true
     */
    public var enabled:Boolean      = true;
    /**
     * 翻页所需的滑动速度阈值。
     * @default 30
     */
    public var touchPow:Number      = 30;
    /**
     * 翻页所需的滑动距离比例（相对 <code>touchSize.x</code>）。
     * @default 0.3
     */
    public var touchDis:Number      = 0.3;
    /**
     * 手动指定单元间距；为 <code>null</code> 时按尺寸自动计算。
     * @default null
     */
    public var gap:Point;
    /**
     * 首页列表起始位置；为 <code>null</code> 时用自动计算的首点。
     * @default null
     */
    public var listPos:Point;
    /** @private 单元尺寸 */
    private var _unitSize:Point;
    /** @private 按下时的内容 X */
    private var _oldContentX:Number = 0;
    /** @private 翻页目标 X */
    private var _tweenX:Number      = 0;
    /** @private 各页 KyoTileList */
    private var _lists:Vector.<KyoTileList>;
    /** @private 实际使用的间距 */
    private var _gap:Point          = new Point();
    /** @private 列表子项是否可交互 */
    private var _listEnable:Boolean = true;
    /** @private 按下时舞台 mouseX */
    private var _oldX:Number;
    /** @private 当前帧滑动速度 */
    private var _mouseSpd:Number    = 0;
    /** @private 上一帧 mouseX */
    private var _curMouseX:Number   = -1;
    /** @private 翻页 Tween */
    private var _tween:TweenLite;

    /**
     * 当前水平间距。
     * @return 间距 X。
     */
    public function get gapX():Number {
        return _gap.x;
    }

    /**
     * 当前垂直间距。
     * @return 间距 Y。
     */
    public function get gapY():Number {
        return _gap.y;
    }

    /**
     * 显示对象总数。
     * @return <code>displays</code> 长度。
     */
    public function get length():uint {
        return _displays.length;
    }

    /** @private */
    [ArrayElementType('flash.display.DisplayObject')]
    private var _displays:Array;

    /**
     * 全部图标显示对象。
     * @return 数组。
     * @default null
     */
    [ArrayElementType('flash.display.DisplayObject')]
    public function get displays():Array {
        return _displays;
    }

    /**
     * @private 拖拽时禁用/恢复子项交互，并对 <code>IPhoneBtn</code> 调 <code>onDrag</code>。
     */
    private function set listsEnable(v:Boolean):void {
        if (_listEnable == v) {
            return;
        }
        _listEnable = v;
        for each (var i:KyoTileList in _lists) {
            i.mouseEnabled = i.mouseChildren = v;
            for each (var n:DisplayObject in i.displays) {
                if (n is IPhoneBtn) {
                    (n as IPhoneBtn).onDrag();
                }
            }
        }
    }

    /**
     * 对所有显示对象调用同名方法。
     * @param fun 方法名。
     * @param params 传给该方法的参数。
     * @example
     * <listing version="3.0">
     * list.callAll('destroy');
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
     * 移除监听、销毁子列表并终止 Tween。
     * @example
     * <listing version="3.0">
     * list.destroy();
     * </listing>
     */
    public function destroy():void {
        removeEventListener(Event.ENTER_FRAME, onEnterFrame);
        removeEventListener(MouseEvent.MOUSE_DOWN, downHandler);
        if (stage) {
            stage.removeEventListener(MouseEvent.MOUSE_UP, upHandler);
        }

        for each (var i:KyoTileList in _lists) {
            i.callAll('destroy');
        }

        removeLists();

        if (_tween) {
            _tween.pause();
            _tween.kill();
            _tween = null;
        }
    }

    /**
     * 设置全部显示对象并重建分页。
     * @param v 显示对象数组。
     * @example
     * <listing version="3.0">
     * list.setDisplay([icon0, icon1]);
     * </listing>
     * @see #addDisplay()
     * @see #update()
     */
    [ArrayElementType('flash.display.DisplayObject')]
    public function setDisplay(v:Array):void {
        _displays = v;
        update();
    }

    /**
     * 追加一个显示对象；末页未满则直接加入，否则重建分页。
     * @param d 显示对象。
     */
    public function addDisplay(d:DisplayObject):void {
        _displays ||= [];
        _displays.push(d);
        if (!_lists) {
            update();
            return;
        }
        var list:KyoTileList = _lists[_lists.length - 1];
        if (!list || list.displays.length >= perPage) {
            var cp:int = curPage;
            update();
            if (curPage != cp) {
                goPage(cp, false);
            }
            return;
        }
        list.addDisplay(d);
    }

    /**
     * 按引用移除显示对象。
     * @param d 要移除的对象。
     * @param updateNow 是否立即 <code>update</code>，默认 <code>true</code>。
     * @see #removeDisplayAt()
     */
    public function removeDisplay(d:DisplayObject, updateNow:Boolean = true):void {
        var id:int = displays.indexOf(d);
        if (id == -1) {
            return;
        }
        removeDisplayAt(id, updateNow);
    }

    /**
     * 按索引移除显示对象。
     * @param id 索引。
     * @param updateNow 是否立即重建，默认 <code>true</code>。
     */
    public function removeDisplayAt(id:int, updateNow:Boolean = true):void {
        displays.splice(id, 1);
        if (updateNow) {
            update();
        }
    }

    /**
     * 按当前 <code>displays</code> 重建各页列表与命中区域。
     * @example
     * <listing version="3.0">
     * list.update();
     * </listing>
     */
    public function update():void {
        _gap = new Point();

        var vRow:int = Math.ceil(perPage / hRow);

        var firstP:Point = new Point();

        if (!gap) {
            var l1:Number = _unitSize.x;
            var l:Number  = touchSize.x - l1;
            _gap.x   = (l - _unitSize.x) / (hRow - 1) - _unitSize.x;
            firstP.x = l1 / 2;

            var h1:Number = _unitSize.y;
            var h2:Number = touchSize.y - h1;
            _gap.y   = (h2 - _unitSize.y) / (vRow - 1) - _unitSize.y;
            firstP.y = h1 / 2;
        }
        else {
            _gap.x = gap.x;
            _gap.y = gap.y;
        }

        if (listPos) {
            firstP = listPos.clone();
        }

        removeLists();
        _lists = new Vector.<KyoTileList>();
        updateScrollRect();

        curPage   = 1;
        totalPage = Math.ceil(_displays.length / perPage);

        for (var i:int = curPage; i <= totalPage; i++) {
            var list:KyoTileList = createList(i);
            list.x = firstP.x + (i - 1) * touchSize.x;
            list.y = firstP.y;
            addChild(list);
            _lists.push(list);
        }

        graphics.clear();
        graphics.beginFill(KyoColor.BLACK, 0);
        graphics.drawRect(0, 0, touchSize.x * totalPage, touchSize.y * 1.1);
        graphics.endFill();

        _tweenX = 0;
        resumeComplete();
    }

    /**
     * 翻到下一页。
     * @return 是否成功翻页。
     * @see #goPage()
     */
    public function nextPage():Boolean {
        return goPage(curPage + 1);
    }

    /**
     * 翻到上一页。
     * @return 是否成功翻页。
     * @see #goPage()
     */
    public function prevPage():Boolean {
        return goPage(curPage - 1);
    }

    /**
     * 跳转到指定页。
     * @param p 页码（从 1 起）。
     * @param tween 是否使用缓动，默认 <code>true</code>。
     * @return 是否实际发生翻页。
     * @example
     * <listing version="3.0">
     * list.goPage(2);
     * </listing>
     */
    public function goPage(p:int, tween:Boolean = true):Boolean {
        if (p < 1) {
            return false;
        }
        if (p > totalPage) {
            return false;
        }
        if (curPage == p) {
            return false;
        }

        removeEventListener(MouseEvent.MOUSE_DOWN, downHandler);

        _tweenX += (curPage - p) * touchSize.x;
        if (tween) {
            _tween = TweenLite.to(this, .5, {
                contentX  : _tweenX,
                onComplete: resumeComplete,
                onUpdate  : updateScrollRect
            });
        }
        else {
            contentX = _tweenX;
            resumeComplete();
        }

        curPage = p;
        dispatchEvent(new IphoneIconListEvent(IphoneIconListEvent.PAGE_CHANGE));

        return true;
    }

    /**
     * @private 移除各页列表。
     */
    private function removeLists():void {
        for each (var i:KyoTileList in _lists) {
            try {
                removeChild(i);
            }
            catch (e:Error) {
                trace(e);
            }
        }
        _lists = null;
    }

    /**
     * @private 按 <code>contentX</code> 更新 scrollRect。
     */
    private function updateScrollRect():void {
        scrollRect = new Rectangle(-contentX, 0, touchSize.x, touchSize.y * 1.1);
    }

    /**
     * @private 创建指定页的 <code>KyoTileList</code>。
     */
    private function createList(page:int):KyoTileList {
        var ss:int = (page - 1) * perPage;
        if (ss < 0) {
            ss = 0;
        }

        var list:KyoTileList = new KyoTileList(
            _displays.slice(ss, Math.min(ss + perPage, _displays.length)),
            hRow,
            perPage / hRow
        );
        list.lockSize  = true;
        list.unitySize = _unitSize;
        list.gap       = _gap;
        list.update();

        return list;
    }

    /**
     * @private 翻页/回弹结束后恢复交互。
     */
    private function resumeComplete():void {
        contentX     = _tweenX;
        _oldContentX = 0;

        updateScrollRect();
        addEventListener(MouseEvent.MOUSE_DOWN, downHandler);
        listsEnable = true;
    }

    /**
     * @private 松手后按速度/位移决定翻页或回弹。
     */
    private function resume():void {
        if (Math.abs(_mouseSpd) > touchPow) {
            if (_mouseSpd > 0) {
                if (prevPage()) {
                    return;
                }
            }
            else {
                if (nextPage()) {
                    return;
                }
            }
        }
        else {
            if (Math.abs(contentX - _oldContentX) > touchSize.x * touchDis) {
                if (contentX > _oldContentX) {
                    if (prevPage()) {
                        return;
                    }
                }
                else {
                    if (nextPage()) {
                        return;
                    }
                }
            }
        }

        _tweenX = _oldContentX;
        _tween  = TweenLite.to(this, .5, {
            contentX : _tweenX,
            onComplete: resumeComplete,
            onUpdate  : updateScrollRect
        });
    }

    /**
     * @private 按下开始拖拽跟踪。
     */
    private function downHandler(e:Event):void {
        if (!enabled) {
            return;
        }

        removeEventListener(MouseEvent.MOUSE_DOWN, downHandler);

        if (stage == null) {
            return;
        }

        _oldX        = stage.mouseX;
        _oldContentX = contentX;
        _curMouseX   = stage.mouseX;

        if (!hasEventListener(Event.ENTER_FRAME)) {
            addEventListener(Event.ENTER_FRAME, onEnterFrame);
        }

        stage.removeEventListener(MouseEvent.MOUSE_UP, upHandler);
        stage.addEventListener(MouseEvent.MOUSE_UP, upHandler);
    }

    /**
     * @private 抬起结束拖拽。
     */
    private function upHandler(e:Event):void {
        removeEventListener(Event.ENTER_FRAME, onEnterFrame);

        resume();

        var stg:Stage = e.currentTarget as Stage;
        if (stg) {
            stg.removeEventListener(MouseEvent.MOUSE_UP, upHandler);
        }
        if (stage) {
            stage.removeEventListener(MouseEvent.MOUSE_UP, upHandler);
        }
    }

    /**
     * @private 拖拽中更新位移与速度。
     */
    private function onEnterFrame(e:Event):void {
        if (stage == null) {
            return;
        }

        _mouseSpd  = stage.mouseX - _curMouseX;
        _curMouseX = stage.mouseX;

        var msx:Number = stage.mouseX;
        var pp:int     = 1;
        if (msx > _oldX) {
            if (curPage <= 1) {
                pp = 2;
            }
        }
        else {
            if (curPage >= totalPage) {
                pp = 2;
            }
        }
        contentX = (msx - _oldX) / pp + _oldContentX;
        if (Math.abs(msx - _oldX) > 5) {
            listsEnable = false;
        }
        updateScrollRect();
    }

}
}