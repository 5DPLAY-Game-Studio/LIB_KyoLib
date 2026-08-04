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
import flash.display.Sprite;
import flash.events.ContextMenuEvent;
import flash.net.registerClassAlias;
import flash.ui.ContextMenu;
import flash.ui.ContextMenuItem;
import flash.utils.ByteArray;
import flash.utils.Dictionary;
import flash.utils.describeType;
import flash.utils.getDefinitionByName;
import flash.utils.getQualifiedClassName;

/**
 * 对象赋值、克隆与反射辅助。
 *
 * @see #setValueByObject()
 * @see #clone()
 */
public class KyoUtils {
    /** @private 已 registerClassAlias 的限定名 */
    private static var _cloneAliasRegistered:Object = {};
    /** @private 根类限定名 → AMF 相关类型名列表 */
    private static var _cloneTypeNameCache:Object   = {};

    /**
     * 按 Object 键值给目标对象赋值（含 Boolean / Number 类型转换）。
     * @param setter 目标对象。
     * @param obj 源键值；为 <code>null</code> 时忽略。
     * @example
     * <listing version="3.0">
     * KyoUtils.setValueByObject(vo, {x: 1, y: 2});
     * </listing>
     */
    public static function setValueByObject(setter:*, obj:Object):void {
        if (!obj) {
            return;
        }
        for (var i:String in obj) {
            var tmp:* = undefined;
            try {
                tmp = setter[i];
            }
            catch (e:Error) {
            }

            var vv:Object = obj[i];
            if (tmp === undefined) {
                try {
                    setter[i] = vv;
                }
                catch (e:Error) {
                    trace('KyoUtils.setValueByObject :', e);
                }
                continue;
            }

            if (setter[i] is Boolean) {
                if (vv is Boolean) {
                    setter[i] = vv;
                }
                else if (vv is Number) {
                    setter[i] = vv == 1;
                }
                else if (vv is String) {
                    setter[i] = vv == 'true' || vv == '1';
                }
            }
            else if (setter[i] is Number) {
                setter[i] = Number(vv);
            }
            else {
                setter[i] = vv;
            }
        }
    }

    /**
     * 克隆属性。
     * @param to 目标对象。
     * @param from 源对象。
     * @param keys 属性键列表；为 <code>null</code> 时拷贝 from 全部可枚举键。
     * @return <code>to</code>。
     * @example
     * <listing version="3.0">
     * KyoUtils.cloneValue(dst, src, ['x', 'y']);
     * </listing>
     */
    public static function cloneValue(to:*, from:*, keys:Array = null):* {
        if (keys) {
            for each (var i:String in keys) {
                to[i] = from[i];
            }
        }
        else {
            for (var j:String in from) {
                to[j] = from[j];
            }
        }

        return to;
    }

    /**
     * 浅拷贝动态 Object 的可枚举键。
     * @param from 源对象。
     * @return 新对象。
     * @example
     * <listing version="3.0">
     * var o:Object = KyoUtils.cloneObject(src);
     * </listing>
     * @see #clone()
     */
    public static function cloneObject(from:Object):Object {
        var o:Object = {};
        for (var j:String in from) {
            o[j] = from[j];
        }

        return o;
    }

    /**
     * 统计 Object 中真值属性个数。
     * @param obj 对象。
     * @return 个数。
     * @example
     * <listing version="3.0">
     * KyoUtils.getObjLength(map);
     * </listing>
     */
    public static function getObjLength(obj:Object):int {
        if (!obj) {
            return 0;
        }

        var l:int = 0;
        for each (var i:* in obj) {
            if (i) {
                l++;
            }
        }

        return l;
    }

    /**
     * 通过 ByteArray AMF 深拷贝。
     *
     * <p>拷贝前按类型图 <code>registerClassAlias</code>（有缓存），尽量还原为原 Class。
     * 仅复制公开属性；目标类构造不可带参。浅拷动态对象 见 <code>cloneObject</code>。</p>
     *
     * @param v 源对象；为 <code>null</code> 则返回 <code>null</code>。
     * @return 深拷贝；构造带参等导致还原失败时为 <code>null</code>。
     * @example
     * <listing version="3.0">
     * var c:* = KyoUtils.clone(obj);
     * </listing>
     * @see #cloneObject()
     */
    public static function clone(v:Object):* {
        if (v == null) {
            return null;
        }

        var names:Array = collectCloneTypeNames(v);
        for each (var aliasName:String in names) {
            ensureCloneClassAlias(aliasName);
        }

        var bytes:ByteArray = new ByteArray();
        bytes.writeObject(v);
        bytes.position = 0;

        var className:String  = getQualifiedClassName(v);
        var objectClass:Class = getDefinitionByName(className) as Class;
        try {
            return bytes.readObject() as objectClass;
        }
        catch (e:ArgumentError) {
            // 带参构造等导致 AMF 还原失败
        }

        return null;
    }

    /** @private 收集源对象类型图上的限定名（按根类缓存） */
    private static function collectCloneTypeNames(object:*):Array {
        var rootName:String = getQualifiedClassName(object);
        var cached:Array    = _cloneTypeNameCache[rootName] as Array;
        if (cached) {
            return cached;
        }

        var result:Array          = [];
        var dictionary:Dictionary = new Dictionary();
        var xml:XML               = describeType(object);

        addCloneTypeName(dictionary, String(xml.@name));
        collectCloneTypeAttrs(dictionary, xml.extendsClass);
        collectCloneTypeAttrs(dictionary, xml.implementsInterface);
        collectCloneTypeAttrs(dictionary, xml.variable);
        collectCloneTypeAttrs(dictionary, xml.accessor);

        for each (var methodXml:XML in xml.method) {
            addCloneTypeName(dictionary, String(methodXml.@returnType));
            collectCloneTypeAttrs(dictionary, methodXml.parameter);
        }

        for (var key:* in dictionary) {
            result.push(String(key));
        }

        _cloneTypeNameCache[rootName] = result;

        return result;
    }

    /** @private */
    private static function collectCloneTypeAttrs(dict:Dictionary, list:XMLList):void {
        for each (var node:XML in list) {
            addCloneTypeName(dict, String(node.@type));
        }
    }

    /** @private */
    private static function addCloneTypeName(dict:Dictionary, typeName:String):void {
        if (!typeName || typeName == 'void' || typeName == '*' || typeName == 'null') {
            return;
        }
        dict[typeName] = true;
    }

    /** @private 按限定名注册 AMF 别名（只注册一次） */
    private static function ensureCloneClassAlias(qname:String):void {
        if (_cloneAliasRegistered[qname]) {
            return;
        }
        try {
            var cls:Class = getDefinitionByName(qname) as Class;
            if (cls) {
                registerClassAlias(qname, cls);
                _cloneAliasRegistered[qname] = true;
            }
        }
        catch (e:Error) {
            // 内置类型或无法解析时跳过
        }
    }

    /**
     * 获取对象类定义。
     * @param o 任意对象。
     * @return 对应 Class。
     * @example
     * <listing version="3.0">
     * var c:Class = KyoUtils.getClass(sprite);
     * </listing>
     */
    public static function getClass(o:Object):Class {
        var className:String = getQualifiedClassName(o);

        return getDefinitionByName(className) as Class;
    }

    /**
     * 自定义右键菜单。
     * @param main 目标 Sprite。
     * @param menu 菜单项标题数组。
     * @param select 选中回调，参数为菜单标题；可省略。
     * @example
     * <listing version="3.0">
     * KyoUtils.customMenu(root, ['About'], onSelect);
     * </listing>
     */
    public static function customMenu(main:Sprite, menu:Array, select:Function = null):void {
        var cm:ContextMenu = new ContextMenu();
        for each (var i:String in menu) {
            var menuItem:ContextMenuItem = new ContextMenuItem(i);
            if (select != null) {
                menuItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, function (e:ContextMenuEvent):void {
                    select((e.currentTarget as ContextMenuItem).caption);
                });
            }
            cm.customItems.push(menuItem);
        }
        if (main.stage) {
            main.stage.showDefaultContextMenu = false;
        }
        main.contextMenu = cm;
    }

    /**
     * 将实体类对象转换为 object，包含 public var 属性。
     * @param item 实体实例。
     * @return 属性键值 Object。
     * @example
     * <listing version="3.0">
     * var o:Object = KyoUtils.itemToObject(vo);
     * </listing>
     */
    public static function itemToObject(item:*):Object {
        var xml:XML  = describeType(item);
        var o:Object = {};

        for each (var j:XML in xml.variable) {
            var k:String = j.@name;
            o[k]         = item[k];
        }

        return o;
    }

    /**
     * 获取对象所有 public var 属性名。
     * @param item 目标对象。
     * @return 属性名称数组。
     * @example
     * <listing version="3.0">
     * var keys:Array = KyoUtils.getItemVariables(vo);
     * </listing>
     */
    public static function getItemVariables(item:*):Array {
        var xml:XML = describeType(item);
        var a:Array = [];

        for each (var j:XML in xml.variable) {
            a.push(String(j.@name));
        }

        return a;
    }

    /**
     * 克隆类定义的对象，所有 public var 的属性将进行克隆（仅支持简单类型的属性）。
     * @param from 源实例。
     * @return 新实例。
     * @example
     * <listing version="3.0">
     * var copy:* = KyoUtils.cloneSimpleClassObject(vo);
     * </listing>
     */
    public static function cloneSimpleClassObject(from:*):* {
        var o:Object  = itemToObject(from);
        var cls:Class = getDefinitionByName(getQualifiedClassName(from)) as Class;
        var newItem:* = new cls();
        setValueByObject(newItem, o);

        return newItem;
    }

}
}
