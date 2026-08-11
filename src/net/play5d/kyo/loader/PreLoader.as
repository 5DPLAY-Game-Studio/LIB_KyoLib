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
import flash.display.MovieClip;
import flash.events.Event;
import flash.events.ProgressEvent;
import flash.utils.getDefinitionByName;

/**
 * 文档类预加载基类：显示进度条，完成后跳到第 2 帧并实例化 <code>_mainClass</code>。
 *
 * <p>子类需设置 <code>_mainClass</code> 为完整类名。</p>
 *
 * @see LoaderBar
 * @see #initialize()
 */
public class PreLoader extends MovieClip {
    /**
     * 构造函数；加入舞台后自动 <code>initialize</code>。
     */
    public function PreLoader() {
        super();
        addEventListener(Event.ADDED_TO_STAGE, onAddStage);

        stop();
    }

    /**
     * 是否显示内置 <code>LoaderBar</code>。
     * @default true
     */
    public var showLoadbar:Boolean = true;
    /**
     * 加载完成后要实例化的主类全名。
     * @default null
     */
    protected var _mainClass:String;
    /**
     * 进度条实例。
     * @default null
     */
    protected var _loadbar:LoaderBar;

    /**
     * 创建进度条并监听 <code>loaderInfo</code> 进度。
     * @param width 可用宽（当前实现未用于布局，保留形参）。
     * @param height 可用高（当前实现未用于布局，保留形参）。
     * @example
     * <listing version="3.0">
     * initialize(stage.stageWidth, stage.stageHeight);
     * </listing>
     */
    public function initialize(width:Number, height:Number):void {
        if (showLoadbar) {
            _loadbar           = new LoaderBar(800, 15);
            _loadbar.x         = 100;
            _loadbar.y         = 500;
            _loadbar.color     = 0x426F00;
            _loadbar.lineColor = 0x64A600;
            _loadbar.backColor = 0x1C2F00;
            _loadbar.initialize();
            addChild(_loadbar);
        }

        loaderInfo.addEventListener(ProgressEvent.PROGRESS, onLoadProgress);
        loaderInfo.addEventListener(Event.COMPLETE, loadComplete);
    }

    /**
     * 进度更新钩子；默认驱动进度条。
     * @param p 0~1。
     * @example
     * <listing version="3.0">
     * onProgress(0.5);
     * </listing>
     */
    protected function onProgress(p:Number):void {
        if (_loadbar) {
            _loadbar.update(p);
        }
    }

    /**
     * 加载完成：移除进度条，跳到第 2 帧并添加主类实例。
     * @param e 完成事件。
     * @example
     * <listing version="3.0">
     * // 由 loaderInfo COMPLETE 触发
     * loadComplete(e);
     * </listing>
     */
    protected function loadComplete(e:Event):void {
        if (_loadbar) {
            removeChild(_loadbar);
        }

        loaderInfo.removeEventListener(ProgressEvent.PROGRESS, onLoadProgress);
        loaderInfo.removeEventListener(Event.COMPLETE, loadComplete);

        this.gotoAndStop(2);

        var main:Class = getDefinitionByName(_mainClass) as Class;
        addChild(new main());
    }

    /**
     * @private
     */
    private function onAddStage(e:Event):void {
        initialize(stage.stageWidth - 200, stage.stageHeight - 50);
    }

    /**
     * @private
     */
    private function onLoadProgress(e:ProgressEvent):void {
        onProgress(e.bytesLoaded / e.bytesTotal);
    }
}
}
