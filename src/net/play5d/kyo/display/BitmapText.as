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

package net.play5d.kyo.display {
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.filters.BitmapFilter;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.text.TextField;
import flash.text.TextFormat;

/**
 * 基于 <code>TextField</code> 绘制的位图文本显示对象。
 *
 * <p>文本样式变更后可通过 <code>autoUpdate</code> 自动调用 <code>update()</code> 重绘，
 * 也可手动调用 <code>update()</code> 刷新 <code>bitmapData</code>。</p>
 *
 * @see #text
 * @see #update()
 * @see #destroy()
 * @example
 * <listing version="3.0">
 * var label:BitmapText = new BitmapText(true, 0xffffff);
 * label.text = 'Hello';
 * addChild(label);
 * </listing>
 */
public class BitmapText extends Bitmap {
    /**
     * @param autoUpdate 样式或文本变更后是否自动重绘。
     * @param color 初始文本颜色。
     * @param filers 绘制后依次应用的位图滤镜数组；为 <code>null</code> 时不应用滤镜。
     * @default autoUpdate true
     * @default color 0
     * @default filers null
     */
    public function BitmapText(autoUpdate:Boolean = true, color:uint = 0, filers:Array = null) {
        this.autoUpdate = autoUpdate;
        this.smoothing  = true;

        _filers = filers;
        _tf     = new TextField();

        this.color = color;
    }

    /**
     * 样式或文本变更后是否自动调用 <code>update()</code> 重绘。
     * @default true
     */
    public var autoUpdate:Boolean;
    /** @private 内部 TextField，用于测量与绘制文本 */
    protected var _tf:TextField;
    /** @private 默认文本格式 */
    private var _format:TextFormat = new TextFormat();
    /** @private 绘制后应用的位图滤镜列表 */
    private var _filers:Array;
    /** @private 指定绘制宽度；为 0 时按文本宽度自适应 */
    private var _width:Number      = 0;
    /** @private 指定绘制高度；为 0 时按文本高度自适应 */
    private var _height:Number     = 0;

    /** @private */
    public override function set width(value:Number):void {
        _width    = value;
        _tf.width = value;
    }

    /** @private */
    public override function set height(value:Number):void {
        _height    = value;
        _tf.height = value;
    }

    /**
     * 内部用于测量与绘制的 <code>TextField</code>。
     * @return 内部文本域实例。
     */
    public function get textfield():TextField {
        return _tf;
    }

    /**
     * 字体名称。
     * @return 当前 <code>TextFormat.font</code>。
     */
    public function get font():String {
        return _format.font;
    }

    /** @private */
    public function set font(v:String):void {
        _format.font = v;
        if (autoUpdate) {
            update();
        }
    }

    /**
     * 字号。
     * @return 当前 <code>TextFormat.size</code>。
     */
    public function get fontSize():Object {
        return _format.size;
    }

    /** @private */
    public function set fontSize(v:Object):void {
        _format.size = v;
        if (autoUpdate) {
            update();
        }
    }

    /**
     * 文本颜色。
     * @return ARGB 颜色值。
     */
    public function get color():uint {
        return _format.color as uint;
    }

    /** @private */
    public function set color(value:uint):void {
        _format.color = value;
        if (autoUpdate) {
            update();
        }
    }

    /**
     * 文本对齐方式，对应 <code>TextFormat.align</code>。
     * @return 对齐字符串（如 <code>left</code>、<code>center</code>、<code>right</code>）。
     */
    public function get align():String {
        return _format.align;
    }

    /** @private */
    public function set align(value:String):void {
        _format.align = value;
    }

    /**
     * 显示文本内容。
     * @return 当前文本。
     * @example
     * <listing version="3.0">
     * label.text = 'SCORE: 100';
     * </listing>
     */
    public function get text():String {
        return _tf.text;
    }

    /** @private */
    public function set text(value:String):void {
        _tf.text = value;
        if (autoUpdate) {
            update();
        }
    }

    /**
     * 默认文本格式；赋值后替换内部 <code>_format</code> 引用。
     * @return 当前默认 <code>TextFormat</code>。
     */
    public function get defaultTextFormat():TextFormat {
        return _format;
    }

    /** @private */
    public function set defaultTextFormat(v:TextFormat):void {
        _format = v;
        if (autoUpdate) {
            update();
        }
    }

    /**
     * 内部 <code>TextField</code> 的宽度（布局尺寸，非纯文本宽度）。
     * @return 文本域宽度。
     */
    public function get textWidth():Number {
        return _tf.width;
    }

    /** @private */
    public function set textWidth(v:Number):void {
        _tf.width = v;
    }

    /**
     * 内部 <code>TextField</code> 的高度。
     * @return 文本域高度。
     */
    public function get textHeight():Number {
        return _tf.height;
    }

    /** @private */
    public function set textHeight(v:Number):void {
        _tf.height = v;
    }

    /** @private */
    public function set leading(v:Number):void {
        _format.leading = v;
    }

    /** @private */
    public function set letterSpacing(v:Number):void {
        _format.letterSpacing = v;
    }

    /**
     * 启用多行与自动换行。
     * @param v 为 <code>true</code> 时开启多行并启用 <code>wordWrap</code>。
     * @example
     * <listing version="3.0">
     * label.multiLine(true);
     * label.text = 'line1\nline2';
     * </listing>
     */
    public function multiLine(v:Boolean):void {
        _tf.multiline = v;
        _tf.wordWrap  = true;
    }

    /**
     * 对指定区间应用文本格式。
     *
     * <p><code>beginIndex</code>、<code>endIndex</code> 为 <code>-1</code> 时表示全文。</p>
     *
     * @param f 要应用的格式。
     * @param beginIndex 起始字符索引。
     * @param endIndex 结束字符索引（不含）。
     * @default beginIndex -1
     * @default endIndex -1
     * @example
     * <listing version="3.0">
     * var fmt:TextFormat = new TextFormat('Arial', 14, 0xff0000);
     * label.setTextFormat(fmt);
     * </listing>
     */
    public function setTextFormat(f:TextFormat, beginIndex:int = -1, endIndex:int = -1):void {
        _tf.setTextFormat(f, beginIndex, endIndex);
        if (autoUpdate) {
            update();
        }
    }

    /**
     * 返回文本实际渲染宽度（不含布局留白）。
     * @return <code>TextField.textWidth</code>。
     * @example
     * <listing version="3.0">
     * var w:Number = label.getTextWidth();
     * </listing>
     */
    public function getTextWidth():Number {
        return _tf.textWidth;
    }

    /**
     * 将当前文本绘制为透明背景的 <code>BitmapData</code> 并替换显示位图。
     *
     * <p>无内部 <code>TextField</code> 或文本为空时不执行。绘制前会应用
     * <code>defaultTextFormat</code>；若 <code>width</code>、<code>height</code> 未指定则按文本尺寸加一字号边距自适应。</p>
     *
     * @example
     * <listing version="3.0">
     * label.autoUpdate = false;
     * label.text = 'batch';
     * label.update();
     * </listing>
     */
    public function update():void {
        if (!_tf) {
            return;
        }
        if (!_tf.text) {
            return;
        }

        var size:int = int(_format.size) > 0 ? int(_format.size) : 12;

        _tf.setTextFormat(_format);

        _tf.width  = (_width != 0) ? _width : (_tf.textWidth + size);
        _tf.height = (_height != 0) ? _height : (_tf.textHeight + size);

        var bd:BitmapData = new BitmapData(_tf.width, _tf.height, true, 0);

        bd.draw(_tf);
        if (_filers) {
            for each(var i:BitmapFilter in _filers) {
                bd.applyFilter(bd, new Rectangle(0, 0, bd.width, bd.height), new Point(), i);
            }
        }

        if (bitmapData) {
            bitmapData.dispose();
        }

        bitmapData = bd;
    }

    /**
     * 从显示列表移除并释放位图与内部引用。
     * @example
     * <listing version="3.0">
     * label.destroy();
     * </listing>
     */
    public function destroy():void {
        try {
            parent.removeChild(this);
        }
        catch (e:Error) {
        }
        if (bitmapData) {
            bitmapData.dispose();
        }
        _tf = null;
    }

}
}