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
/**
 * XML 属性映射到 VO，以及安全取数值。
 *
 * @see #encodeToVO()
 * @see #getNumber()
 */
public class KyoXMLUtils {
    /**
     * 将 XML 子节点属性写入 VO 实例列表或字典。
     * @param xml <code>XML</code> 或 <code>XMLList</code>。
     * @param voClass VO 类。
     * @param KeyId 非空时按该属性作字典键；否则返回数组。
     * @param childrenKey 非空时把子节点 XMLList 写入该字段。
     * @param childrenMatches 要按名写入 VO 的子节点名数组。
     * @return 数组或字典。
     * @example
     * <listing version="3.0">
     * var list:Object = KyoXMLUtils.encodeToVO(xml, ItemVO);
     * </listing>
     */
    public static function encodeToVO(xml:Object, voClass:Class, KeyId:String = null, childrenKey:String = null,
                                      childrenMatches:Array = null
    ):Object {
        var o:Object  = KeyId ? {} : [];
        var x:XMLList = xml is XMLList ? xml as XMLList : (xml as XML).children();

        for each(var i:XML in x) {
            var att:XMLList = i.attributes();
            var vo:*        = new voClass();
            for (var j:int = 0; j < att.length(); j++) {
                var k:String = att[j].name();
                var v:String = att[j];
                try {
                    if (vo[k] is Boolean && (v == '0' || v == '1')) {
                        vo[k] = int(v) == 1;
                    }
                    else {
                        vo[k] = v;
                    }
                }
                catch (e:Error) {
                    trace(e);
                }
            }

            if (childrenKey) {
                vo[childrenKey] = i.children();
            }

            if (childrenMatches) {
                for each(var l:String in childrenMatches) {
                    var vv:XMLList = i.child(l);
                    if (vv) {
                        vo[l] = vv;
                    }
                }
            }

            if (o is Array) {
                (o as Array).push(vo);
            }
            else {
                var kk:String = i.attribute(KeyId);
                o[kk]         = vo;
            }
        }

        return o;
    }

    /**
     * 将 XML 直接子节点收集为数组。
     * @param x 根 XML。
     * @return 子节点数组。
     * @example
     * <listing version="3.0">
     * var a:Array = KyoXMLUtils.encodeToString(xml);
     * </listing>
     */
    public static function encodeToString(x:XML):Array {
        var o:Array = [];
        for each(var i:XML in x.children()) {
            o.push(i);
        }
        return o;
    }

    /**
     * 将 XMLList 转为 uint，无效时返回默认值。
     * @param x XMLList。
     * @param defaultNumber 默认值。
     * @return 无符号整数。
     * @example
     * <listing version="3.0">
     * var n:uint = KyoXMLUtils.getUint(xml.@id);
     * </listing>
     */
    public static function getUint(x:XMLList, defaultNumber:uint = 0):uint {
        var v:int = int(x);
        if (v > 0) {
            return v;
        }
        return defaultNumber;
    }

    /**
     * 将 XMLList 转为 Number，NaN 时返回默认值。
     * @param x XMLList。
     * @param defaultNumber 默认值。
     * @return 数值。
     * @example
     * <listing version="3.0">
     * var n:Number = KyoXMLUtils.getNumber(xml.@v);
     * </listing>
     */
    public static function getNumber(x:XMLList, defaultNumber:Number = 0):Number {
        var v:Number = Number(x);
        if (!isNaN(v)) {
            return v;
        }
        return defaultNumber;
    }

    /**
     * 构造函数（本类以静态方法使用，通常无需实例化）。
     */
    public function KyoXMLUtils() {
    }

}
}
