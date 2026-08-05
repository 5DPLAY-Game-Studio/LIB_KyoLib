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
import flash.events.Event;
import flash.events.MouseEvent;

/**
 * 选中变化时分派（<code>Event.SELECT</code>）。
 * @eventType flash.events.Event.SELECT
 */
[Event(name='select', type='flash.events.Event')]
/**
 * 选项卡容器：按间距排布 <code>ITab</code> 项，点击互斥选中。
 *
 * @see BaseBox
 * @see ITab
 * @see #select()
 * @see #selectedTab
 */
public class TabBox extends BaseBox {
    /**
     * @param gapX 水平间距，默认 5。
     * @param gapY 垂直间距，默认 0。
     */
    public function TabBox(gapX:Number = 5, gapY:Number = 0) {
        this.gapX = gapX;
        this.gapY = gapY;
    }

    /**
     * 当前选中的选项卡。
     * @default null
     */
    public var selectedTab:ITab;
    /** @private 布局光标 X */
    private var _lx:Number;
    /** @private 布局光标 Y */
    private var _ly:Number;

    /**
     * 当前选中项在 <code>instances</code> 中的索引。
     * @return 索引；未选中时为 -1。
     */
    public function get selectedIndex():int {
        return _instances.indexOf(selectedTab);
    }

    /** @inheritDoc */
    protected override function build():void {
        _lx = _ly = 0;
        if (!_instances || _instances.length < 1) {
            return;
        }

        update();
        select(0);
    }

    /** @inheritDoc */
    protected override function buildByRepeater():void {
        if (repeater) {
            _instances = repeater.getItems();
        }

        build();
    }

    /**
     * 按 <code>instances</code> 同步子显示对象（增删）。
     * @example
     * <listing version="3.0">
     * tabBox.update();
     * </listing>
     */
    public function update():void {
        var count:int = numChildren > _instances.length ? numChildren : _instances.length;

        for (var i:int; i < count; i++) {
            var dc:DisplayObject;
            try {
                dc = getChildAt(i);
            }
            catch (err:Error) {
                dc = null;
            }

            var t:ITab = _instances[i];
            if (t && !dc) {
                addChildItem(t);
            }
            if (!t && dc) {
                removeChild(dc);
            }
        }
    }

    /**
     * 按索引选中选项卡。
     * @param id 索引。
     * @example
     * <listing version="3.0">
     * tabBox.select(1);
     * </listing>
     */
    public function select(id:int):void {
        if (_instances) {
            selectTab(_instances[id]);
        }
    }

    /**
     * @private 加入显示列表并监听点击。
     */
    private function addChildItem(d:ITab):void {
        var dp:DisplayObject = (d is DisplayObject) ? d as DisplayObject : d.display;
        dp.x = _lx;
        dp.y = _ly;
        addChild(dp);

        d.addEventListener(MouseEvent.CLICK, mouseHandler, false, 0, true);

        if (gapX > 0) {
            _lx += dp.width + gapX;
        }
        if (gapY > 0) {
            _ly += dp.height + gapY;
        }
    }

    /**
     * @private 互斥设置 selected。
     */
    private function selectTab(v:ITab):void {
        selectedTab = v;
        if (v.selected) {
            return;
        }

        for each (var i:ITab in _instances) {
            i.selected = false;
        }

        v.selected = true;
    }

    /**
     * @private 点击选中并派发 SELECT。
     */
    private function mouseHandler(e:MouseEvent):void {
        selectTab(e.currentTarget as ITab);

        dispatchEvent(new Event(Event.SELECT));
    }

}
}

