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

package net.play5d.kyo.storage {
import flash.net.SharedObject;

/**
 * 本地 <code>SharedObject</code> 读写封装。
 *
 * @see #load()
 * @see #save()
 * @see #clearLocal()
 * @see SaveDataManager
 * @see flash.net.SharedObject
 */
public class KyoSharedObject {
    /**
     * 读取本地 SharedObject 的 data 引用后关闭。
     *
     * <p>返回的是 data 引用，<code>close</code> 之后再改不会写回。<code>getLocal</code> 拿到的是同名现有实例，<code>close</code> 会把这份实例关掉。</p>
     *
     * @param id 本地名。
     * @return data 对象。
     * @example
     * <listing version="3.0">
     * var d:Object = KyoSharedObject.load('save1');
     * </listing>
     */
    public static function load(id:String):Object {
        var so:SharedObject = SharedObject.getLocal(id);
        var d:Object        = so.data;
        so.close();

        return d;
    }

    /**
     * 清空后写入对象字段并 flush。
     *
     * <p><code>data</code> 为 null 时抛错。字段按引用写入，不深拷贝。不检查 <code>flush</code> 的返回值，用户拒绝扩容时可能还没写完就 <code>close</code>。</p>
     *
     * @param id 本地名。
     * @param data 要写入的键值。
     * @example
     * <listing version="3.0">
     * KyoSharedObject.save('save1', {score: 1});
     * </listing>
     */
    public static function save(id:String, data:Object):void {
        var so:SharedObject = SharedObject.getLocal(id);
        so.clear();

        for (var i:String in data) {
            so.data[i] = data[i];
        }

        so.flush();
        so.close();
    }

    /**
     * 清空指定本地 SharedObject。
     *
     * <p>只 <code>clear</code>，不 <code>close</code>。同名实例若仍被别处持有，内容也会被清掉。</p>
     *
     * @param id 本地名。
     * @example
     * <listing version="3.0">
     * KyoSharedObject.clearLocal('save1');
     * </listing>
     */
    public static function clearLocal(id:String):void {
        var so:SharedObject = SharedObject.getLocal(id);
        so.clear();
    }
}
}
