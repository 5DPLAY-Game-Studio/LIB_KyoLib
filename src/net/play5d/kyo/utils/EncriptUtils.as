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
import com.adobe.crypto.AES;
import com.adobe.crypto.MD5;
import com.hurlant.util.Hex;

import flash.utils.ByteArray;

/**
 * MD5 / AES 加解密工具（历史拼写 <code>Encript</code>）。
 *
 * @see #md5()
 * @see #encriptAES()
 * @see #decryptAES()
 */
public class EncriptUtils {
    /**
     * 对字节做 MD5（大文件仅取头尾各 1KB）。
     * @param bytes 源字节。
     * @return MD5 十六进制字符串。
     * @example
     * <listing version="3.0">
     * var h:String = EncriptUtils.md5(ba);
     * </listing>
     */
    public static function md5(bytes:ByteArray):String {
        return hashBytes(bytes);
    }

    /**
     * AES-128-CBC 加密。
     * @param source <code>String</code> 或 <code>ByteArray</code>。
     * @param key 十六进制密钥字符串。
     * @param iv 十六进制 IV 字符串。
     * @return 密文字节。
     * @example
     * <listing version="3.0">
     * var c:ByteArray = EncriptUtils.encriptAES('hi', key, iv);
     * </listing>
     */
    public static function encriptAES(source:Object, key:String, iv:String):ByteArray {
        var keyByte:ByteArray = Hex.toArray(key);
        var ivByte:ByteArray  = Hex.toArray(iv);

        var aes:AES = new AES(keyByte, ivByte, 'aes-128-cbc', 'null');

        var byte:ByteArray;

        if (source is String) {
            byte = new ByteArray();
            byte.writeUTFBytes(source as String);
        }
        if (source is ByteArray) {
            byte = source as ByteArray;
        }

        var encryptBytes:ByteArray = aes.encrypt(byte);

        return encryptBytes;
    }

    /**
     * AES 解密为 UTF-8 字符串。
     * @param code 密文字节。
     * @param key 十六进制密钥。
     * @param iv 十六进制 IV。
     * @return 明文。
     * @example
     * <listing version="3.0">
     * var s:String = EncriptUtils.decryptAES(code, key, iv);
     * </listing>
     */
    public static function decryptAES(code:ByteArray, key:String, iv:String):String {
        var byte:ByteArray = decryptAESBytes(code, key, iv);

        byte.position     = 0;
        var decode:String = byte.readUTFBytes(byte.length);

        return decode;
    }

    /**
     * AES 解密为字节。
     * @param code 密文字节。
     * @param key 十六进制密钥。
     * @param iv 十六进制 IV。
     * @return 明文字节。
     * @example
     * <listing version="3.0">
     * var b:ByteArray = EncriptUtils.decryptAESBytes(code, key, iv);
     * </listing>
     */
    public static function decryptAESBytes(code:ByteArray, key:String, iv:String):ByteArray {
        var keyByte:ByteArray = Hex.toArray(key);
        var ivByte:ByteArray  = Hex.toArray(iv);

        var aes:AES        = new AES(keyByte, ivByte, 'aes-128-cbc', 'null');
        var byte:ByteArray = aes.decrypt(code);

        return byte;
    }

    /**
     * @private 采样头尾字节后 MD5。
     */
    private static function hashBytes(fileBytes:ByteArray):String {
        var length:int = fileBytes.length;
        var bytes:ByteArray;

        if (length < 1024 * 2) {
            bytes = fileBytes;
        }
        else {
            bytes = new ByteArray();
            bytes.writeBytes(fileBytes, 0, 1024);
            bytes.writeBytes(fileBytes, length - 1024, 1024);
        }

        var hash:String = MD5.hashBinary(bytes);
        return hash;
    }

}
}
