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

package net.play5d.kyo.display.bitmap {
import flash.display.BitmapData;
import flash.geom.Point;
import flash.geom.Rectangle;

/**
 * 位图字体，使用 Starling 位图字体 XML + 贴图格式。
 *
 * <p>根据字符表将字符串拼成一张透明底的 <code>BitmapData</code>，供 <code>BitmapFontText</code> 等显示。</p>
 *
 * @see BitmapFontText
 * @see BitmapFontLoader
 * @see #renderText()
 */
public class BitmapFont {
    /**
     * 由字体 XML 与源贴图构建字符缓存。
     * @param fontXML Starling 位图字体 XML（含 <code>info</code>、<code>chars</code>）。
     * @param fontBitmap 字体贴图。
     */
    public function BitmapFont(fontXML:XML, fontBitmap:BitmapData) {
        _source    = fontBitmap;
        _charWidth = fontXML.info.@size;

        for each (var i:XML in fontXML.chars.char) {
            var char:InsCharVO = new InsCharVO(i);
            if (_charHeight < char.height) {
                _charHeight = char.height;
            }
            if (_yOffsetMin > char.yoffset) {
                _yOffsetMin = char.yoffset;
            }
            _fontCache[char.id] = char;
        }
    }

    /**
     * 字与字之间的额外间距（像素）。
     * @default 0
     */
    public var charGap:Number     = 0;
    /**
     * 空格（字符码 32）的宽度；为 0 时回退为 <code>_charWidth + charGap</code>。
     * @default 0
     */
    public var spaceGap:Number    = 0;
    /**
     * 绘制时整体 X 偏移。
     * @default 0
     */
    public var offsetX:Number     = 0;
    /**
     * 绘制时整体 Y 偏移。
     * @default 0
     */
    public var offsetY:Number     = 0;
    /** @private 源贴图 */
    private var _source:BitmapData;
    /** @private 字符码 → 字形缓存 */
    private var _fontCache:Object = {};
    /** @private 单字参考宽度（取自 XML <code>info.&#64;size</code>） */
    private var _charWidth:int;
    /** @private 单字高度（取各字形最大 height） */
    private var _charHeight:int;
    /** @private 各字形 yoffset 最小值，用于基线对齐 */
    private var _yOffsetMin:int   = 999;

    /**
     * 将字符串渲染为位图。
     *
     * <p>未知字符跳过；空格按 <code>spaceGap</code> 或默认字宽推进光标。</p>
     *
     * @param str 要绘制的文本。
     * @return 含全部字形的透明 <code>BitmapData</code>（调用方负责 dispose）。
     * @example
     * <listing version="3.0">
     * var bd:BitmapData = font.renderText('Hello');
     * </listing>
     * @see #charGap
     * @see #spaceGap
     */
    public function renderText(str:String):BitmapData {
        var charWidth:Number  = 0;
        var outputChars:Array = [];
        var i:int;
        var char:InsCharVO;

        for (i = 0; i < str.length; i++) {
            var code:int = str.charCodeAt(i);

            if (code == 32 && spaceGap) {
                charWidth += spaceGap;
                continue;
            }

            char = getChar(code);
            if (!char) {
                if (code == 32) {
                    charWidth += _charWidth + charGap;
                }
                continue;
            }

            char.x = charWidth;
            charWidth += char.width + charGap;
            outputChars.push(char);
        }

        if (charGap < 0) {
            charWidth -= charGap;
        }

        var output:BitmapData = new BitmapData(charWidth, _charHeight, true, 0);

        for (i = 0; i < outputChars.length; i++) {
            char = outputChars[i];

            output.copyPixels(
                _source,
                new Rectangle(char.sx, char.sy, char.width, char.height),
                new Point(char.x + offsetX, char.y + (char.yoffset - _yOffsetMin) + offsetY),
                null,
                null,
                true
            );
        }

        return output;
    }

    /** @private 按字符码取字形副本；无缓存则返回 <code>null</code>。 */
    private function getChar(code:int):InsCharVO {
        var char:InsCharVO = _fontCache[code];
        if (char) {
            return char.clone();
        }

        return null;
    }

}
}

/**
 * 单个字形数据（由字体 XML 的 <code>char</code> 节点解析）。
 * @private
 */
internal class InsCharVO {
    /**
     * @private
     * @param xml 可选的 <code>char</code> 节点；为 <code>null</code> 时仅建空实例。
     */
    public function InsCharVO(xml:XML = null) {
        _xml = xml;
        if (xml) {
            id      = xml.@id;
            sx      = xml.@x;
            sy      = xml.@y;
            width   = xml.@width;
            height  = xml.@height;
            xoffset = xml.@xoffset;
            yoffset = xml.@yoffset;
        }
    }

    /** @private 在输出图中的绘制 X */
    public var x:Number = 0;
    /** @private 在输出图中的绘制 Y */
    public var y:Number = 0;
    /** @private 字符码（与 XML <code>id</code> 对应） */
    public var id:String;
    /** @private 源贴图中的 X */
    public var sx:int;
    /** @private 源贴图中的 Y */
    public var sy:int;
    /** @private 字形宽 */
    public var width:int;
    /** @private 字形高 */
    public var height:int;
    /** @private XML xoffset */
    public var xoffset:int;
    /** @private XML yoffset */
    public var yoffset:int;
    /** @private 原始 XML，供 clone */
    private var _xml:XML;

    /**
     * @private 基于同一 XML 再解析一份，避免布局时改写缓存。
     * @return 新 <code>InsCharVO</code>。
     */
    public function clone():InsCharVO {
        return new InsCharVO(_xml);
    }

}
