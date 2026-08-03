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

package net.play5d.kyo.crypto {
import com.hurlant.crypto.symmetric.DESKey;
import com.hurlant.util.Base64;

import flash.utils.ByteArray;

/**
 * DES 加解密工具（基于 as3crypto 的 <code>DESKey</code>）。
 *
 * <p>明文以 UTF-8 写入 <code>ByteArray</code> 后加密，密文以 Base64 字符串输出；解密过程相反。</p>
 *
 * @see #encrypt()
 * @see #decrypt()
 * @see #keystr
 * @author bardpub
 */
public class DES {
    /**
     * DES 密钥字符串，写入密钥 <code>ByteArray</code> 时按 UTF-8 编码。
     * @default '123456'
     */
    public static var keystr:String = '123456';

    /**
     * 使用当前 <code>keystr</code> 对字符串加密。
     * @param str 明文。
     * @return Base64 编码的密文；<code>str</code> 为空时行为取决于底层 <code>DESKey</code>。
     * @example
     * <listing version="3.0">
     * DES.keystr = '12345678';
     * var cipher:String = DES.encrypt('hello');
     * </listing>
     * @see #decrypt()
     * @see #keystr
     */
    public static function encrypt(str:String):String {
        var des:DESKey    = getDESKey();
        var tmp:ByteArray = string2byteArray(str);
        des.encrypt(tmp);
        return Base64.encodeByteArray(tmp);
    }

    /**
     * 使用当前 <code>keystr</code> 对 Base64 密文解密。
     * @param str Base64 编码的密文。
     * @return 解密后的 UTF-8 明文。
     * @example
     * <listing version="3.0">
     * var plain:String = DES.decrypt(cipher);
     * </listing>
     * @see #encrypt()
     * @see #keystr
     */
    public static function decrypt(str:String):String {
        var des:DESKey    = getDESKey();
        var tmp:ByteArray = Base64.decodeToByteArray(str);
        des.decrypt(tmp);
        return byteArray2string(tmp);
    }

    /**
     * @private 将字符串转为 UTF-8 <code>ByteArray</code>。
     */
    private static function string2byteArray(str:String):ByteArray {
        var bytes:ByteArray;
        if (str) {
            bytes = new ByteArray();
            bytes.writeUTFBytes(str);
        }
        return bytes;
    }

    /**
     * @private 将 <code>ByteArray</code> 按 UTF-8 读为字符串。
     */
    private static function byteArray2string(bytes:ByteArray):String {
        var str:String;
        if (bytes) {
            bytes.position = 0;
            str            = bytes.readUTFBytes(bytes.length);
        }
        return str;
    }

    /**
     * @private 按 <code>keystr</code> 构造 <code>DESKey</code>。
     */
    private static function getDESKey():DESKey {
        var key:ByteArray = new ByteArray();
        key.writeUTFBytes(keystr);
        return new DESKey(key);
    }

}
}
