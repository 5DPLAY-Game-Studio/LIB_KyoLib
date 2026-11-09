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
 * 基于 SharedObject 的存档管理：读写键值、可选自动 flush。
 *
 * @see #save()
 * @see #updateData()
 * @see KyoSharedObject
 */
public class SaveDataManager {
    /**
     * 构造存档管理器。
     * @param soName SharedObject 本地名。
     * @param localPath 可选路径，默认 <code>null</code>。
     * @param secure 是否安全存储，默认 <code>false</code>。
     * @param autoSave 修改后是否自动 <code>save</code>，默认 <code>false</code>。
     * @example
     * <listing version="3.0">
     * var mgr:SaveDataManager = new SaveDataManager('save1', null, false, true);
     * </listing>
     */
    public function SaveDataManager(
        soName   :String,
        localPath:String = null,
        secure   :Boolean = false,
        autoSave :Boolean = false
    ) {
        _so       = SharedObject.getLocal(soName, localPath, secure);
        _autoSave = autoSave;
    }

    /** @private */
    private var _so:SharedObject;
    /** @private */
    private var _autoSave:Boolean;

    /**
     * 是否已写入过存档标记 <code>_has_data_</code>。
     *
     * <p>只有布尔 <code>true</code> 才算有存档。</p>
     *
     * @return 是否有存档。
     * @example
     * <listing version="3.0">
     * if (mgr.hasData) { }
     * </listing>
     */
    public function get hasData():Boolean {
        return _so.data._has_data_ == true;
    }

    /**
     * 底层 SharedObject.data。
     *
     * <p>赋值会先清空再写入各字段，并按构造时的 <code>autoSave</code> 决定是否 <code>save</code>。值为 null 时，清空之后会抛错。</p>
     *
     * @return data 对象。
     * @example
     * <listing version="3.0">
     * var d:Object = mgr.data;
     * </listing>
     */
    public function get data():Object {
        return _so.data;
    }

    /**
     * @private 清空后用对象整体覆盖并可选自动保存。
     */
    public function set data(value:Object):void {
        clear();
        addDataByObject(value);
        tryAutoSave();
    }

    /**
     * 按键取值。
     * @param key 键名。
     * @return 值。
     * @example
     * <listing version="3.0">
     * var v:* = mgr.getDataByKey('score');
     * </listing>
     */
    public function getDataByKey(key:String):* {
        return _so.data[key];
    }

    /**
     * 更新单键并可选自动保存。
     * @param key 键名。
     * @param value 值。
     * @example
     * <listing version="3.0">
     * mgr.updateData('score', 100);
     * </listing>
     */
    public function updateData(key:String, value:Object):void {
        _so.data[key] = value;
        tryAutoSave();
    }

    /**
     * 合并对象字段到 data。
     *
     * <p>不删除原有键。<code>o</code> 为 null 时抛错。</p>
     *
     * @param o 键值对象。
     * @example
     * <listing version="3.0">
     * mgr.addDataByObject({a: 1});
     * </listing>
     */
    public function addDataByObject(o:Object):void {
        for (var i:String in o) {
            _so.data[i] = o[i];
        }
        tryAutoSave();
    }

    /**
     * 清空 SharedObject。
     *
     * <p>立刻清空磁盘上的同名存档，不会自动 <code>save</code>。</p>
     *
     * @example
     * <listing version="3.0">
     * mgr.clear();
     * </listing>
     */
    public function clear():void {
        _so.clear();
    }

    /**
     * 写入标记与时间戳并 flush。
     *
     * <p>标记键是 <code>_has_data_</code>，时间键是 <code>date_time</code>。不关闭 SharedObject，也不检查 <code>flush</code> 是否被用户拒绝。</p>
     *
     * @example
     * <listing version="3.0">
     * mgr.save();
     * </listing>
     */
    public function save():void {
        if (!hasData) {
            _so.data._has_data_ = true;
        }
        _so.data.date_time = new Date();
        _so.flush();
    }

    /**
     * 若开启 autoSave 则调用 <code>save</code>。
     * @example
     * <listing version="3.0">
     * mgr.tryAutoSave();
     * </listing>
     */
    public function tryAutoSave():void {
        if (_autoSave) {
            save();
        }
    }
}
}
