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

package net.play5d.kyo.effect {
import flash.geom.ColorTransform;

/**
 * 残影常用的预设 <code>ColorTransform</code>（红 / 蓝偏移）。
 *
 * <p>返回的是惰性创建的共享实例，请勿就地修改其属性以免影响其它调用方。</p>
 *
 * @see DisplayEffect#ghostShadow()
 * @see #red
 * @see #blue
 */
public class GhostShadowColorTransform {
    /** @private */
    private static var _red:ColorTransform;
    /** @private */
    private static var _blue:ColorTransform;

    /**
     * 红色偏移残影用的颜色变换（<code>redOffset = 255</code>）。
     * @return 共享的 <code>ColorTransform</code> 实例。
     * @example
     * <listing version="3.0">
     * DisplayEffect.ghostShadow(mc, 0.1, 1, GhostShadowColorTransform.red);
     * </listing>
     */
    public static function get red():ColorTransform {
        if (!_red) {
            _red           = new ColorTransform();
            _red.redOffset = 255;
        }

        return _red;
    }

    /**
     * 蓝色偏移残影用的颜色变换（<code>blueOffset = 255</code>）。
     * @return 共享的 <code>ColorTransform</code> 实例。
     * @example
     * <listing version="3.0">
     * DisplayEffect.ghostShadow(mc, 0.1, 1, GhostShadowColorTransform.blue);
     * </listing>
     */
    public static function get blue():ColorTransform {
        if (!_blue) {
            _blue            = new ColorTransform();
            _blue.blueOffset = 255;
        }

        return _blue;
    }
}
}
