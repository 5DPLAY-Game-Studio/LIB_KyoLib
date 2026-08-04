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
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IOErrorEvent;
import flash.net.URLLoader;
import flash.net.URLLoaderDataFormat;
import flash.net.URLRequest;
import flash.utils.ByteArray;

/**
 * <code>EVENT_PARSE_ERROR</code> 事件的 <code>type</code> 属性值。
 *
 * @eventType parseError
 */
[Event(name='parseError', type='flash.events.Event')]
/**
 * 加载完成时派发（解析成功后）。
 *
 * @eventType flash.events.Event.COMPLETE
 */
[Event(name='complete', type='flash.events.Event')]
/**
 * 网络 IO 错误时转发。
 *
 * @eventType flash.events.IOErrorEvent.IO_ERROR
 */
[Event(name='ioError', type='flash.events.IOErrorEvent')]
/**
 * 以二进制加载 BMP 并解析为 <code>Bitmap</code>（支持 1/4/8/24 位）。
 *
 * @see #load()
 * @see #content
 * @see #EVENT_PARSE_ERROR
 */
public class BMPLoader extends EventDispatcher {
    /**
     * 非 BMP 或解析失败时派发的事件类型。
     * @eventType parseError
     */
    public static const EVENT_PARSE_ERROR:String = 'parseError';

    /**
     * 构造函数。
     */
    public function BMPLoader() {
    }

    /**
     * 解析成功后的位图。
     */
    public var content:Bitmap;

    /** @private */
    private var _loader:URLLoader;
    /** @private */
    private var _binaryArray:ByteArray;
    /** @private 当前解析游标（字节数） */
    private var _crtPos:int = 0;
    /** @private */
    private var isBm:Boolean;
    /** @private */
    private var bfSize:Number;
    /** @private */
    private var bfoffBits:Number;
    /** @private */
    private var biSize:int;
    /** @private */
    private var biWidth:int;
    /** @private */
    private var biHeight:int;
    /** @private */
    private var biPlanes:int;
    /** @private */
    private var biBitCount:int;
    /** @private */
    private var biCompression:int;
    /** @private */
    private var biSizeImage:Number;
    /** @private */
    private var biXpelsPerMeter:Number;
    /** @private */
    private var biYPelsPerMeter:Number;
    /** @private */
    private var biClrUsed:int;
    /** @private */
    private var biClrImportant:int;
    /** @private */
    private var arrayRGBQuad:Array;
    /** @private */
    private var int1:int, int2:int, int3:int, int4:int;
    /** @private */
    private var short1:int;
    /** @private */
    private var short2:int;

    /**
     * 按 URL 以二进制加载 BMP。
     * @param uq 请求。
     * @example
     * <listing version="3.0">
     * var bmp:BMPLoader = new BMPLoader();
     * bmp.addEventListener(Event.COMPLETE, onOk);
     * bmp.load(new URLRequest('a.bmp'));
     * </listing>
     */
    public function load(uq:URLRequest):void {
        _loader            = new URLLoader();
        _loader.dataFormat = URLLoaderDataFormat.BINARY;
        _loader.addEventListener(IOErrorEvent.IO_ERROR, onError);
        _loader.addEventListener(Event.COMPLETE, onBmpLoadComplete);
        _loader.load(uq);
    }

    /**
     * 读取 1 个有符号字节，并推进游标。
     * @return 字节值。
     * @example
     * <listing version="3.0">
     * var b:int = bmp.readByte();
     * </listing>
     */
    public function readByte():int {
        _crtPos++;

        return _binaryArray.readByte();
    }

    /**
     * 读取 1 个无符号字节，并推进游标。
     * @return 无符号字节。
     * @example
     * <listing version="3.0">
     * var b:int = bmp.readUnsignedByte();
     * </listing>
     */
    public function readUnsignedByte():int {
        _crtPos++;

        return _binaryArray.readUnsignedByte();
    }

    /**
     * 以小端序读取 16 位无符号值。
     * @return 16 位值。
     * @example
     * <listing version="3.0">
     * var s:int = bmp.readShort();
     * </listing>
     */
    public function readShort():int {
        _crtPos += 2;
        short1 = _binaryArray.readUnsignedByte();
        short2 = _binaryArray.readUnsignedByte();

        return short2 << 8 | short1;
    }

    /**
     * 以小端序读取 32 位无符号值。
     * @return 32 位值。
     * @example
     * <listing version="3.0">
     * var u:int = bmp.readUint();
     * </listing>
     */
    public function readUint():int {
        _crtPos += 4;
        int1 = _binaryArray.readUnsignedByte();
        int2 = _binaryArray.readUnsignedByte();
        int3 = _binaryArray.readUnsignedByte();
        int4 = _binaryArray.readUnsignedByte();

        return int4 << 24 | int3 << 16 | int2 << 8 | int1;
    }

    /**
     * 以小端序读取 32 位有符号值。
     * @return 32 位值。
     * @example
     * <listing version="3.0">
     * var n:int = bmp.readInt();
     * </listing>
     */
    public function readInt():int {
        _crtPos += 4;
        int1 = _binaryArray.readByte();
        int2 = _binaryArray.readByte();
        int3 = _binaryArray.readByte();
        int4 = _binaryArray.readByte();

        return int4 << 24 | int3 << 16 | int2 << 8 | int1;
    }

    /**
     * @private 解析 BMP 头与像素数据。
     */
    private function parseBmpData():BitmapData {
        //设置当前的解析字节数为0
        _crtPos       = 0;
        //位图文件的类型
        var temp1:int = readByte();
        var temp2:int = readByte();
        var bmd:BitmapData;
        if (temp1 != 66 || temp2 != 77) {
            isBm = false;
            trace('这不是一张BMP格式的图片');
            dispatchEvent(new Event(EVENT_PARSE_ERROR));

            return null;
        }
        isBm   = true;
        bfSize = readInt();
        readShort();
        readShort();
        bfoffBits       = readInt();
        biSize          = readInt();
        biWidth         = readUint();
        biHeight        = readUint();
        biPlanes        = readShort();
        biBitCount      = readShort();
        biCompression   = readInt();
        biSizeImage     = readInt();
        biXpelsPerMeter = readInt();
        biYPelsPerMeter = readInt();
        biClrUsed       = readInt();
        biClrImportant  = readInt();

        var i:int, j:int;
        var r:int, g:int, b:int;
        var numline:int = 0;
        if (biBitCount == 24) {
            bmd = new BitmapData(biWidth, biHeight);
            bmd.lock();
            numline = 0;
            for (j = biHeight - 1; j >= 0; j--) {
                numline = 0;
                for (i = 0; i < biWidth; i++) {
                    b = readUnsignedByte();
                    g = readUnsignedByte();
                    r = readUnsignedByte();
                    bmd.setPixel(i, j, r << 16 | g << 8 | b);
                    numline += 3;
                }
                while (numline % 4 != 0) {
                    numline++;
                    readByte();
                }
            }
            bmd.unlock();
        }
        else if (biBitCount == 1 || biBitCount == 4 || biBitCount == 8) {
            var numcolors:int = bfoffBits - _crtPos / 4;
            arrayRGBQuad      = [];
            for (i = 0; i < numcolors; i++) {
                var rgbObj:Object = {};
                rgbObj.b          = readUnsignedByte();
                rgbObj.g          = readUnsignedByte();
                rgbObj.r          = readUnsignedByte();
                readUnsignedByte();
                arrayRGBQuad.push(rgbObj);
            }
            var rgb8:Object;
            bmd = new BitmapData(biWidth, biHeight);
            bmd.lock();
            numline = 0;
            var ix1:int, ix2:int, ix3:int, ix4:int, ix5:int, ix6:int, ix7:int, ix8:int, ix0:int;
            for (j = biHeight - 1; j >= 0; j--) {
                numline = 0;
                for (i = 0; i < biWidth;) {
                    numline += 1;
                    if (biBitCount == 8) {
                        ix1  = readUnsignedByte();
                        rgb8 = arrayRGBQuad[ix1];
                        r    = rgb8.r;
                        g    = rgb8.g;
                        b    = rgb8.b;
                        bmd.setPixel(i, j, r << 16 | g << 8 | b);
                        i++;
                    }
                    else if (biBitCount == 4) {
                        ix1  = readUnsignedByte();
                        ix2  = ix1 >> 4;
                        ix3  = ix1 & 0x0f;
                        rgb8 = arrayRGBQuad[ix2];
                        r    = rgb8.r;
                        g    = rgb8.g;
                        b    = rgb8.b;
                        bmd.setPixel(i, j, r << 16 | g << 8 | b);
                        i++;
                        rgb8 = arrayRGBQuad[ix3];
                        r    = rgb8.r;
                        g    = rgb8.g;
                        b    = rgb8.b;
                        bmd.setPixel(i, j, r << 16 | g << 8 | b);
                        i++;
                    }
                    else if (biBitCount == 1) {
                        ix0 = readUnsignedByte();
                        ix1 = ix0 >> 4 & 8;
                        ix2 = ix0 >> 4 & 4;
                        ix3 = ix0 >> 4 & 2;
                        ix4 = ix0 >> 4 & 1;
                        ix5 = ix0 & 0x0f & 8;
                        ix6 = ix0 & 0x0f & 4;
                        ix7 = ix0 & 0x0f & 2;
                        ix8 = ix0 & 0x0f & 1;

                        rgb8 = arrayRGBQuad[ix1];
                        r    = rgb8.r;
                        g    = rgb8.g;
                        b    = rgb8.b;
                        bmd.setPixel(i, j, r << 16 | g << 8 | b);
                        i++;

                        rgb8 = arrayRGBQuad[ix2];
                        r    = rgb8.r;
                        g    = rgb8.g;
                        b    = rgb8.b;
                        bmd.setPixel(i, j, r << 16 | g << 8 | b);
                        i++;

                        rgb8 = arrayRGBQuad[ix3];
                        r    = rgb8.r;
                        g    = rgb8.g;
                        b    = rgb8.b;
                        bmd.setPixel(i, j, r << 16 | g << 8 | b);
                        i++;

                        rgb8 = arrayRGBQuad[ix4];
                        r    = rgb8.r;
                        g    = rgb8.g;
                        b    = rgb8.b;
                        bmd.setPixel(i, j, r << 16 | g << 8 | b);
                        i++;

                        rgb8 = arrayRGBQuad[ix5];
                        r    = rgb8.r;
                        g    = rgb8.g;
                        b    = rgb8.b;
                        bmd.setPixel(i, j, r << 16 | g << 8 | b);
                        i++;

                        rgb8 = arrayRGBQuad[ix6];
                        r    = rgb8.r;
                        g    = rgb8.g;
                        b    = rgb8.b;
                        bmd.setPixel(i, j, r << 16 | g << 8 | b);
                        i++;

                        rgb8 = arrayRGBQuad[ix7];
                        r    = rgb8.r;
                        g    = rgb8.g;
                        b    = rgb8.b;
                        bmd.setPixel(i, j, r << 16 | g << 8 | b);
                        i++;

                        rgb8 = arrayRGBQuad[ix8];
                        r    = rgb8.r;
                        g    = rgb8.g;
                        b    = rgb8.b;
                        bmd.setPixel(i, j, r << 16 | g << 8 | b);
                        i++;
                    }
                }
                while (numline % 4 != 0) {
                    numline++;
                    readByte();
                }
            }
            bmd.unlock();
        }

        return bmd;
    }

    /**
     * @private
     */
    private function onError(e:IOErrorEvent):void {
        dispatchEvent(e);
    }

    /**
     * @private
     */
    private function onBmpLoadComplete(e:Event):void {
        _loader.removeEventListener(Event.COMPLETE, onBmpLoadComplete);
        _binaryArray       = _loader.data as ByteArray;
        var bmd:BitmapData = parseBmpData();
        _loader            = null;
        if (bmd) {
            content = new Bitmap(bmd, 'auto', true);
            dispatchEvent(new Event(Event.COMPLETE));
        }
    }

}
}
