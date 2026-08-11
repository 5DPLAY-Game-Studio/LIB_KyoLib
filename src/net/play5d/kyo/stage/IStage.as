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

package net.play5d.kyo.stage {
import flash.display.DisplayObject;

/**
 * 场景接口：显示对象、构建与销毁生命周期。
 *
 * @see KyoStageCtrl
 * @see #display
 * @see #build()
 * @see #destroy()
 */
public interface IStage {
    /**
     * 场景显示对象。
     * @return 根显示对象。
     */
    function get display():DisplayObject;

    /**
     * 构建场景（加入显示列表前）。
     * @example
     * <listing version="3.0">
     * stage.build();
     * </listing>
     */
    function build():void;

    /**
     * 加入显示列表后的后续构建。
     * @example
     * <listing version="3.0">
     * stage.afterBuild();
     * </listing>
     */
    function afterBuild():void;

    /**
     * 销毁场景。
     * @param back 销毁完成后的回调；可省略。
     * @example
     * <listing version="3.0">
     * stage.destroy(onDestroyed);
     * </listing>
     */
    function destroy(back:Function = null):void;
}
}
