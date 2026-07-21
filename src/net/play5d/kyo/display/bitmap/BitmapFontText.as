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

package net.play5d.kyo.display.bitmap {
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.geom.ColorTransform;
import flash.geom.Rectangle;

/**
 * 位图字体文本显示对象，内部通过 <code>BitmapFont.translate</code> 生成位图。
 *
 * @see BitmapFont
 * @see #text
 * @see #colorTransform()
 */
public class BitmapFontText extends Bitmap {
    /**
     * @param font 用于渲染文本的位图字体。
     */
    public function BitmapFontText(font:BitmapFont) {
        super(null, 'auto', true);
        _font = font;
    }

    /** @private */
    private var _font:BitmapFont;
    /** @private 着色前的原始位图副本 */
    private var _orgBitmapData:BitmapData;
    /** @private */
    private var _text:String;

    /**
     * 当前显示的文本；赋值时重新生成 <code>bitmapData</code> 并同步宽度。
     * @return 文本内容。
     * @default null
     * @example
     * <listing version="3.0">
     * var label:BitmapFontText = new BitmapFontText(font);
     * label.text = 'SCORE';
     * </listing>
     */
    public function get text():String {
        return _text;
    }

    /** @private */
    public function set text(v:String):void {
        _text      = v;
        bitmapData = _font.translate(v);
        smoothing  = true;
        width      = bitmapData.width;
    }

    /**
     * 对当前位图做颜色变换；传入 <code>null</code> 则恢复到着色前的副本。
     *
     * <p>首次非空调用会缓存当前 <code>bitmapData</code> 的克隆，供之后还原。</p>
     *
     * @param ct 颜色变换；为 <code>null</code> 时还原。
     * @example
     * <listing version="3.0">
     * label.colorTransform(new ColorTransform(1, 0, 0, 1));
     * label.colorTransform(null); // 还原
     * </listing>
     */
    public function colorTransform(ct:ColorTransform):void {
        if (ct == null) {
            if (_orgBitmapData) {
                bitmapData.dispose();
                bitmapData = _orgBitmapData.clone();
            }
            return;
        }

        if (!_orgBitmapData) {
            _orgBitmapData = bitmapData.clone();
        }
        bitmapData.colorTransform(new Rectangle(0, 0, bitmapData.width, bitmapData.height), ct);
    }

    /**
     * 释放原始位图缓存与当前 <code>bitmapData</code>。
     * @example
     * <listing version="3.0">
     * label.dispose();
     * </listing>
     */
    public function dispose():void {
        if (_orgBitmapData) {
            _orgBitmapData.dispose();
            _orgBitmapData = null;
        }
        bitmapData.dispose();
    }

}
}
