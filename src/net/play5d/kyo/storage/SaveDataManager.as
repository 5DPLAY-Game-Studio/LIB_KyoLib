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
     * @param soName SharedObject 本地名。
     * @param localPath 可选路径。
     * @param secure 是否安全存储。
     * @param autoSave 修改后是否自动 <code>save</code>。
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
     * @return 是否有存档。
     */
    public function get hasData():Boolean {
        return _so.data._has_data_ == true;
    }

    /**
     * 底层 SharedObject.data。
     * @return data 对象。
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
