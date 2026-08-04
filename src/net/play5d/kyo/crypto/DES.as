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
 * @see #keyString
 * @author bardpub
 */
public class DES {
    /**
     * DES 密钥字符串，写入密钥 <code>ByteArray</code> 时按 UTF-8 编码。
     * @default '123456'
     */
    public static var keyString:String = '123456';

    /**
     * 使用当前 <code>keyString</code> 对字符串加密。
     * @param str 明文。
     * @return Base64 编码的密文。
     * @example
     * <listing version="3.0">
     * DES.keyString = '12345678';
     * var cipher:String = DES.encrypt('hello');
     * </listing>
     * @see #decrypt()
     * @see #keyString
     */
    public static function encrypt(str:String):String {
        var des:DESKey    = getDESKey();
        var tmp:ByteArray = stringToByteArray(str);
        des.encrypt(tmp);

        return Base64.encodeByteArray(tmp);
    }

    /**
     * 使用当前 <code>keyString</code> 对 Base64 密文解密。
     * @param str Base64 编码的密文。
     * @return 解密后的 UTF-8 明文。
     * @example
     * <listing version="3.0">
     * var plain:String = DES.decrypt(cipher);
     * </listing>
     * @see #encrypt()
     * @see #keyString
     */
    public static function decrypt(str:String):String {
        var des:DESKey    = getDESKey();
        var tmp:ByteArray = Base64.decodeToByteArray(str);
        des.decrypt(tmp);

        return byteArrayToString(tmp);
    }

    /** @private 将字符串转为 UTF-8 <code>ByteArray</code>。 */
    private static function stringToByteArray(str:String):ByteArray {
        if (!str) {
            return null;
        }

        var bytes:ByteArray = new ByteArray();
        bytes.writeUTFBytes(str);

        return bytes;
    }

    /** @private 将 <code>ByteArray</code> 按 UTF-8 读为字符串。 */
    private static function byteArrayToString(bytes:ByteArray):String {
        if (!bytes) {
            return null;
        }

        bytes.position = 0;

        return bytes.readUTFBytes(bytes.length);
    }

    /** @private 按 <code>keyString</code> 构造 <code>DESKey</code>。 */
    private static function getDESKey():DESKey {
        var key:ByteArray = new ByteArray();
        key.writeUTFBytes(keyString);

        return new DESKey(key);
    }

}
}
