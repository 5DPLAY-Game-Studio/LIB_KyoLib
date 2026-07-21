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

package net.play5d.kyo.display.ui {
import flash.display.MovieClip;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.MouseEvent;

/**
 * 基于 MovieClip 帧的按钮：转发点击等鼠标事件，并支持焦点 / 禁用帧切换。
 *
 * @see IKyoButton
 * @see KyoBtnGroup
 * @see #focus
 * @see #enabled
 */
public class KyoMCButton extends EventDispatcher implements IKyoButton {
    /**
     * @param mc 按钮皮肤 MovieClip。
     * @param nornalFrame 普通态帧（标签或帧号），默认 1。
     * @param selectFrame 选中 / 焦点态帧，可选。
     * @param overFrame 悬停态帧，可选（当前未自动切换）。
     * @param unenabledFrame 禁用态帧，可选。
     */
    public function KyoMCButton(
        mc            :MovieClip,
        nornalFrame   :Object = 1,
        selectFrame   :Object = null,
        overFrame     :Object = null,
        unenabledFrame:Object = null
    ) {
        this.mc = mc;
        mc.addEventListener(MouseEvent.CLICK, handler);
        mc.addEventListener(MouseEvent.MOUSE_DOWN, handler);
        mc.addEventListener(MouseEvent.MOUSE_UP, handler);
        _nornalFrame    = nornalFrame;
        _selectFrame    = selectFrame;
        _overFrame      = overFrame;
        _unenabledFrame = unenabledFrame;

        goFrame(_nornalFrame);
    }

    /**
     * 按钮皮肤。
     */
    public var mc:MovieClip;
    /** @private */
    private var _selectFrame:Object;
    /** @private */
    private var _nornalFrame:Object;
    /** @private */
    private var _overFrame:Object;
    /** @private */
    private var _unenabledFrame:Object;

    /**
     * 设置是否焦点：切换到选中帧或普通帧。
     * @param v <code>true</code> 为焦点。
     */
    public function set focus(v:Boolean):void {
        if (v) {
            goFrame(_selectFrame);
        }
        else {
            goFrame(_nornalFrame);
        }
    }

    /**
     * 设置是否可用：控制 <code>mouseEnabled</code> 并切换普通 / 禁用帧。
     * @param v <code>true</code> 为可用。
     */
    public function set enabled(v:Boolean):void {
        mc.mouseEnabled = v;
        if (v) {
            goFrame(_nornalFrame);
        }
        else {
            goFrame(_unenabledFrame);
        }
    }

    /**
     * @private 跳转到指定帧（帧为空则忽略）。
     */
    private function goFrame(frame:Object):void {
        if (frame) {
            mc.gotoAndStop(frame);
        }
    }

    /**
     * @private 将 MC 上的鼠标事件再派发到本实例。
     */
    private function handler(e:Event):void {
        dispatchEvent(e);
    }

}
}
