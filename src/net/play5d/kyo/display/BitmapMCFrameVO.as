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
import flash.display.BitmapData;

/**
 * 位图影片单帧数据：位图、绘制偏移与帧标签。
 *
 * @see BitmapMovieClip
 * @see #destroy()
 */
public class BitmapMCFrameVO {
    /**
     * 绘制时源对象的 X（播放时取负作为位图偏移）。
     * @default 0
     */
    public var x:Number = 0;
    /**
     * 绘制时源对象的 Y。
     * @default 0
     */
    public var y:Number = 0;
    /**
     * 该帧位图数据。
     * @default null
     */
    public var bd:BitmapData;
    /**
     * 帧标签（来自源 MovieClip）。
     * @default null
     */
    public var frameLabel:String;

    /**
     * 释放位图数据。
     * @example
     * <listing version="3.0">
     * vo.destroy();
     * </listing>
     */
    public function destroy():void {
        if (bd) {
            bd.dispose();
            bd = null;
        }
    }
}
}
