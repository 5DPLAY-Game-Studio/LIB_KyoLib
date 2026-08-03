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

package net.play5d.kyo.air.utils {
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.utils.ByteArray;

import net.play5d.kyo.utils.KyoLog;

/**
 * AIR 本地文件读写（应用目录相对路径辅助）。
 *
 * <p>位于 <code>net.play5d.kyo.air</code> 下，表示<strong>仅 AIR</strong>可用（依赖 <code>flash.filesystem</code>）。壳存档等本地 IO 首选本类。</p>
 *
 * @see #writeFile()
 * @see #readTextFile()
 */
public class FileUtils {
    /**
     * 写文件（不存在则新建，存在则按模式写入）。
     * @param url 完整路径。
     * @param content <code>String</code> 或 <code>ByteArray</code>。
     * @param fileMode 默认 <code>FileMode.WRITE</code>。
     * @example
     * <listing version="3.0">
     * FileUtils.writeFile('C:/a.txt', 'hi');
     * </listing>
     */
    public static function writeFile(url:String, content:*, fileMode:String = null):void {
        fileMode ||= FileMode.WRITE;

        try {
            var file:File     = new File(url);
            var fs:FileStream = new FileStream();
            fs.open(file, fileMode);

            if (content is String) {
                fs.writeUTFBytes(content);
            }
            if (content is ByteArray) {
                var byte:ByteArray = content as ByteArray;
                fs.writeBytes(byte, 0, byte.bytesAvailable);
            }

            fs.close();
        }
        catch (e:Error) {
            KyoLog.log('FileUtils.writeFile', e);
        }
    }

    /**
     * 写应用安装目录下的相对路径文件。
     * @param nativeUrl 相对路径（如 <code>abc/1.txt</code>）。
     * @param content 文件数据。
     * @param fileMode 写入模式。
     * @example
     * <listing version="3.0">
     * FileUtils.writeAppFloderFile('cfg/a.txt', 'hi');
     * </listing>
     */
    public static function writeAppFloderFile(nativeUrl:String, content:*, fileMode:String = null):void {
        var url:String = getAppFloderFileUrl(nativeUrl);
        writeFile(url, content, fileMode);
    }

    /**
     * 取得应用目录下相对路径的完整路径。
     * @param nativeUrl 相对路径。
     * @return 完整 native 路径。
     * @example
     * <listing version="3.0">
     * var u:String = FileUtils.getAppFloderFileUrl('cfg/a.txt');
     * </listing>
     */
    public static function getAppFloderFileUrl(nativeUrl:String):String {
        var path:File      = File.applicationDirectory;
        var pathUrl:String = path.nativePath;
        var url:String     = pathUrl + '/' + nativeUrl;
        return url;
    }

    /**
     * 创建目录（完整路径）。
     * @param url 目录完整路径。
     * @example
     * <listing version="3.0">
     * FileUtils.createFloder('C:/temp/logs');
     * </listing>
     */
    public static function createFloder(url:String):void {
        try {
            var dir:File = new File(url);
            dir.createDirectory();
        }
        catch (e:Error) {
            KyoLog.log('FileUtils.createFloder', e);
        }
    }

    /**
     * 以 UTF-8 读取文本文件。
     * @param url 完整路径。
     * @return 文本；失败时为 <code>undefined</code>/<code>null</code>。
     * @example
     * <listing version="3.0">
     * var t:String = FileUtils.readTextFile('C:/a.txt');
     * </listing>
     */
    public static function readTextFile(url:String):String {
        var text:String;
        try {
            var file:File     = new File(url);
            var fs:FileStream = new FileStream();
            fs.open(file, FileMode.READ);
            text = fs.readUTFBytes(fs.bytesAvailable);
            fs.close();
        }
        catch (e:Error) {
            KyoLog.log('FileUtils.readTextFile', url, e);
        }
        return text;
    }

    /**
     * 删除文件。
     * @param url 完整路径。
     * @example
     * <listing version="3.0">
     * FileUtils.del('C:/a.txt');
     * </listing>
     */
    public static function del(url:String):void {
        var file:File = new File(url);
        try {
            file.deleteFile();
        }
        catch (e:Error) {
            KyoLog.log('FileUtils.del', e);
        }
    }

}
}
