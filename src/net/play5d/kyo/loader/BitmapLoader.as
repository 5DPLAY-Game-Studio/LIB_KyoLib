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

/**
 * 通过 <code>ImageLoader</code> 加载位图，成功后写入 <code>bitmap</code> 并以回调返回。
 *
 * <p>与 <code>ImageLoader</code> 不同：本类以 <code>Bitmap</code> 回调，并从 Loader 卸载内容但不 dispose 位图数据。</p>
 *
 * @see #load()
 * @see ImageLoader
 */
public class BitmapLoader {
    /**
     * 构造函数。
     */
    public function BitmapLoader() {
    }

    /**
     * 加载完成的位图；失败或未加载时为 <code>null</code>。
     */
    public var bitmap:Bitmap;
    /**
     * 最近一次 <code>load</code> 的 URL。
     */
    public var url:String;

    /**
     * 加载图片 URL。
     * @param url 图片地址。
     * @param back 成功回调，参数为 <code>Bitmap</code>；可省略。
     * @param fail 失败回调，无参数；可省略。
     * @example
     * <listing version="3.0">
     * var bl:BitmapLoader = new BitmapLoader();
     * bl.load('a.png', onOk, onFail);
     * </listing>
     */
    public function load(url:String, back:Function = null, fail:Function = null):void {
        this.url = url;

        var loader:ImageLoader = new ImageLoader();
        loader.loadImage(url, onOk, onFail);

        function onOk(img:ImageLoader):void {
            bitmap = img.content as Bitmap;
            img.unload();
            if (back != null) {
                back(bitmap);
            }
        }

        function onFail(img:ImageLoader):void {
            if (fail != null) {
                fail();
            }
        }
    }

}
}
