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

package net.play5d.kyo.loader {
import flash.errors.IOError;
import flash.utils.ByteArray;
import flash.utils.Endian;

/**
 * 从 SWF 二进制解析文件头：类型、版本、大小、舞台宽高、帧率与帧数。
 *
 * @see SWFLoader
 * @see #type
 * @see #width
 * @see #height
 */
public class SwfHeaderInfo {
    /**
     * 解析 SWF 头信息。
     * @param bytes 完整或部分 SWF 字节（至少含头与舞台信息所需长度）。
     * @throws IOError 非 FWS/CWS SWF。
     * @example
     * <listing version="3.0">
     * var info:SwfHeaderInfo = new SwfHeaderInfo(bytes);
     * </listing>
     */
    public function SwfHeaderInfo(bytes:ByteArray) {
        setWhRuleList();
        parseByteArray(bytes);
    }

    /**
     * 宽高解析规则表（按控制码）。
     * @default null
     */
    protected var whRuleList:Array;

    /**
     * @private SWF 标识：FWS / CWS
     */
    protected var _type:String;

    /**
     * SWF 标识（FWS 未压缩 / CWS 压缩）。
     * @return SWF 标识字符串。
     */
    public function get type():String {
        return _type;
    }

    /**
     * @private
     */
    protected var _version:uint;

    /**
     * SWF 版本号。
     * @return 版本号。
     */
    public function get version():uint {
        return _version;
    }

    /**
     * @private
     */
    protected var _size:uint;

    /**
     * 文件声明大小（字节）。
     * @return 字节数。
     */
    public function get size():uint {
        return _size;
    }

    /**
     * @private
     */
    protected var _width:uint;

    /**
     * 舞台宽度（像素）。
     * @return 宽度。
     */
    public function get width():uint {
        return _width;
    }

    /**
     * @private
     */
    protected var _height:uint;

    /**
     * 舞台高度（像素）。
     * @return 高度。
     */
    public function get height():uint {
        return _height;
    }

    /**
     * @private
     */
    protected var _fps:uint;

    /**
     * 帧率。
     * @return 帧率。
     */
    public function get fps():uint {
        return _fps;
    }

    /**
     * @private
     */
    protected var _frames:uint;

    /**
     * 时间轴帧数。
     * @return 帧数。
     */
    public function get frames():uint {
        return _frames;
    }

    /**
     * 头信息摘要字符串。
     * @return 如 <code>[type:FWS,version:...]</code>。
     * @example
     * <listing version="3.0">
     * trace(info.toString());
     * </listing>
     */
    public function toString():String {
        return '[type:' + _type + ',version:' + _version + ',size:' + _size + ',width:' + _width + ',height:' +
               _height + ',fps:' + _fps + ',frames:' + _frames + ']';
    }

    /**
     * 解析字节中的 SWF 头。
     * @param bytes 源字节。
     * @throws IOError 非 swf。
     */
    protected function parseByteArray(bytes:ByteArray):void {
        var binary:ByteArray = new ByteArray;
        binary.endian        = Endian.LITTLE_ENDIAN;
        //取前8个字节：标识、版本、文件大小
        bytes.readBytes(binary, 0, 8);
        //前3字节：FWS / CWS
        _type    = binary.readUTFBytes(3);
        //第4字节：版本号
        _version = binary[3];
        //文件大小：字节 8,7,6,5 小端
        _size    = binary[7] << 24 | binary[6] << 16 | binary[5] << 8 | binary[4];

        binary.position        = 8;
        var mainData:ByteArray = new ByteArray;
        bytes.readBytes(mainData);

        if (_type == 'CWS') {
            mainData.uncompress();
        }
        else if (_type != 'FWS') {
            throw new IOError('出错:不是swf文件！');
        }

        //再写入含帧速/帧数等的后续字节
        binary.writeBytes(mainData, 0, 13);

        var ctrlCode:String = binary[8].toString(16);
        var whPos:Array     = getWhRulePosition(whRuleList, ctrlCode);
        var len:int         = whPos[2];

        var s:String = '';
        for (var i:int = 0; i < len; i++) {
            var temp:String = binary[i + 9].toString(16);
            if (temp.length == 1) {
                temp = '0' + temp;
            }
            s += temp;
        }

        _width  = Number('0x' + s.substr(whPos[0][0], 4)) / whPos[0][1];
        _height = Number('0x' + s.substr(whPos[1][0], 4)) / whPos[1][1];

        var pos:int = 8 + len;
        //宽高区后跳一字节为 fps
        _fps    = binary[pos += 2];
        //帧数占两字节，低位在前
        _frames = binary[pos + 2] << 8 | binary[pos + 1];
    }

    /**
     * 初始化宽高控制码规则表。
     * @example
     * <listing version="3.0">
     * setWhRuleList();
     * </listing>
     */
    protected function setWhRuleList():void {
        whRuleList    = [];
        whRuleList[0] = {ctrlCode: '50', position: [[0, 10], [5, 10], 5]};
        whRuleList[1] = {ctrlCode: '58', position: [[1, 40], [6, 10], 6]};
        whRuleList[2] = {ctrlCode: '60', position: [[1, 10], [7, 10], 6]};
        whRuleList[3] = {ctrlCode: '68', position: [[2, 40], [8, 10], 7]};
        whRuleList[4] = {ctrlCode: '70', position: [[2, 10], [9, 10], 7]};
        whRuleList[5] = {ctrlCode: '78', position: [[3, 40], [10, 10], 8]};
        whRuleList[6] = {ctrlCode: '80', position: [[3, 10], [11, 10], 8]};
        whRuleList[7] = {ctrlCode: '88', position: [[2, 40], [12, 10], 9]};
    }

    /**
     * 按控制码取宽高截取规则。
     * @param list 规则表。
     * @param str 控制码十六进制字符串。
     * @return position 数组。
     * @example
     * <listing version="3.0">
     * var pos:Array = getWhRulePosition(whRuleList, '50');
     * </listing>
     */
    private static function getWhRulePosition(list:Array, str:String):Array {
        for (var i:String in list) {
            if (list[i].ctrlCode == str) {
                break;
            }
        }

        return list[i].position;
    }

}
}
