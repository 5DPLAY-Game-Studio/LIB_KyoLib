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
/**
 * 数据重复器：按 <code>dataProvider</code> 批量创建 <code>bindClass</code> 实例并绑定属性。
 *
 * @see BaseBox#repeater
 * @see #getItems()
 * @see #bindProperty
 */
public class KyoRepeater {
    /**
     * 构造空重复器。
     */
    public function KyoRepeater() {
    }

    /**
     * 数据源数组。
     * @default null
     */
    public var dataProvider:Array;
    /**
     * 每项要实例化的类。
     * @default null
     */
    public var bindClass:Class;
    /**
     * 属性绑定：
     * <ul>
     * <li><code>String</code>：写入该项同名属性（数据无该键则整项赋给该属性）</li>
     * <li><code>Array</code>：按属性名列表从数据对象拷贝</li>
     * </ul>
     * @default null
     */
    public var bindProperty:Object;

    /**
     * 根据当前配置生成全部项实例。
     * @return 新建实例数组。
     * @example
     * <listing version="3.0">
     * var items:Array = repeater.getItems();
     * </listing>
     */
    public function getItems():Array {
        var items:Array = [];
        for (var i:int; i < dataProvider.length; i++) {
            items.push(newItem(dataProvider[i]));
        }

        return items;
    }

    /**
     * @private 创建单项并按 <code>bindProperty</code> 赋值。
     */
    private function newItem(data:Object):Object {
        var item:Object = new bindClass();
        if (bindProperty) {
            if (bindProperty is String) {
                item[bindProperty] = bindProperty in data ? data[bindProperty] : data;
            }
            else if (bindProperty is Array) {
                for each (var prop:String in bindProperty as Array) {
                    item[prop] = data[prop];
                }
            }
        }

        return item;
    }

}
}

