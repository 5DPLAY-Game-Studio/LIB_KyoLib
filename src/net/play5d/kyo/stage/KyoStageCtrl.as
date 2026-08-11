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
import flash.display.Sprite;
import flash.events.EventDispatcher;
import flash.utils.getQualifiedClassName;
import flash.utils.setTimeout;

import net.play5d.kyo.stage.effect.IStageFadeEffect;
import net.play5d.kyo.stage.events.KyoStageEvent;

/**
 * 切换场景时派发。
 *
 * @eventType net.play5d.kyo.stage.events.KyoStageEvent.CHANGE_STATE
 */
[Event(name='CHANGE_STATE', type='net.play5d.kyo.stage.events.KyoStageEvent')]
/**
 * 主场景与弹出层控制器：切换 <code>IStage</code>、管理层叠与淡入淡出效果。
 *
 * @see IStage
 * @see #goStage()
 * @see #addLayer()
 * @see net.play5d.kyo.stage.events.KyoStageEvent
 */
public class KyoStageCtrl extends EventDispatcher {
    /**
     * 构造场景控制器。
     * @param mainStage 承载场景与层的根容器。
     * @example
     * <listing version="3.0">
     * var ctrl:KyoStageCtrl = new KyoStageCtrl(root);
     * </listing>
     */
    public function KyoStageCtrl(mainStage:Sprite) {
        _mainStage = mainStage;
    }

    /**
     * 切换场景时暂时关闭鼠标交互的毫秒数；0 表示不关闭。
     * @default 0
     */
    public var changeStateMouseGap:int = 0;
    /** @private */
    private var _mainStage:Sprite;
    /** @private */
    private var _curStage:IStage;
    /** @private */
    private var _layers:Array          = [];

    /**
     * 当前主场景。
     * @return 当前 <code>IStage</code>。
     */
    public function get currentStage():IStage {
        return _curStage;
    }

    /**
     * 是否没有任何弹出层。
     * @return <code>true</code> 表示无层。
     */
    public function get noneLayer():Boolean {
        return _layers.length == 0;
    }

    /**
     * @private
     */
    private function set stageMouseChildren(v:Boolean):void {
        if (_mainStage.stage) {
            _mainStage.stage.mouseChildren = v;
        }
    }

    /**
     * 切换主场景。
     * @param stg 新场景。
     * @param sameChange 与当前同类时是否仍切换。
     * @param buildAfterDestroy 为 <code>true</code> 时等旧场景 <code>destroy</code> 回调后再构建。
     * @return 是否实际发起了切换（同类且 <code>sameChange</code> 为 false 时返回 false）。
     * @example
     * <listing version="3.0">
     * ctrl.goStage(new HomeStage());
     * </listing>
     */
    public function goStage(stg:IStage, sameChange:Boolean = false, buildAfterDestroy:Boolean = false):Boolean {
        function detoryComplete():void {
            try {
                _mainStage.removeChild(_curStage.display);
            }
            catch (e:Error) {
                trace('KyoStageCtrl: goStage:', e);
            }

            _curStage = null;
            newStage();
        }

        function newStage():void {
            if (changeStateMouseGap > 0) {
                stageMouseChildren = false;
                setTimeout(function ():void {
                    stageMouseChildren = true;
                }, changeStateMouseGap);
            }

            _curStage = stg;
            _curStage.build();
            _mainStage.addChild(_curStage.display);
            _curStage.afterBuild();
        }

        if (!sameChange) {
            var classname:String  = getQualifiedClassName(stg);
            var classname2:String = getQualifiedClassName(_curStage);
            if (classname == classname2) {
                return false;
            }
        }
        if (_curStage) {
            if (buildAfterDestroy) {
                _curStage.destroy(detoryComplete);
            }
            else {
                _curStage.destroy();
                detoryComplete();
            }
        }
        else {
            newStage();
        }

        dispatchEvent(new KyoStageEvent(KyoStageEvent.CHANGE_STATE, stg));

        return true;
    }

    /**
     * 显示弹出层。
     * @param layer 弹出层场景。
     * @param x 横坐标；默认 0。传 <code>NaN</code> 时水平居中。
     * @param y 纵坐标；默认 0。传 <code>NaN</code> 时垂直居中。
     * @param removeElse 为 <code>true</code> 时先关闭其他层。
     * @param effect 淡入效果；可省略。
     * @param addBack 加入并效果结束后的回调；可省略。
     * @example
     * <listing version="3.0">
     * ctrl.addLayer(dlg, NaN, NaN, true, new ZoomEffect());
     * </listing>
     */
    public function addLayer(
            layer:IStage, x:Number = 0, y:Number = 0, removeElse:Boolean = false, effect:IStageFadeEffect = null,
            addBack:Function = null
    ):void {
        if (removeElse) {
            removeAllLayer();
        }
        layer.build();

        var sw:Number = _mainStage.stage.stageWidth;
        var sh:Number = _mainStage.stage.stageHeight;

        var dw:Number = layer.display.width * _mainStage.scaleX;
        var dh:Number = layer.display.height * _mainStage.scaleY;

        if (isNaN(x)) {
            layer.display.x = (sw - dw) / 2;
        }
        else {
            layer.display.x = x;
        }
        if (isNaN(y)) {
            layer.display.y = (sh - dh) / 2;
        }
        else {
            layer.display.y = y;
        }
        _mainStage.addChild(layer.display);
        if (effect) {
            effect.fadeIn(layer, effectBack);
        }
        else {
            effectBack();
        }

        function effectBack():void {
            layer.afterBuild();
            if (addBack != null) {
                addBack();
            }
        }

        _layers.push(layer);
    }

    /**
     * 是否已存在指定层（实例或类型）。
     * @param layer <code>IStage</code> 实例或 <code>Class</code>。
     * @return 是否存在。
     * @example
     * <listing version="3.0">
     * if (ctrl.hasLayer(MyDlg)) { }
     * </listing>
     */
    public function hasLayer(layer:Object):Boolean {
        for each(var i:IStage in _layers) {
            if (layer is IStage) {
                if (i == layer) {
                    return true;
                }
            }
            if (layer is Class) {
                var c:Class = layer as Class;
                if (i is c) {
                    return true;
                }
            }
        }
        return false;
    }

    /**
     * 移除弹出层。
     * @param layer 目标层。
     * @param effect 淡出效果；可省略。
     * @param removeBack 移除完成后的回调；可省略。
     * @example
     * <listing version="3.0">
     * ctrl.removeLayer(dlg);
     * </listing>
     */
    public function removeLayer(layer:IStage, effect:IStageFadeEffect = null, removeBack:Function = null):void {

        if (effect) {
            effect.fadeOut(layer, effectFin);
        }
        else {
            effectFin();
        }

        function effectFin():void {
            try {
                _mainStage.removeChild(layer.display);
                layer.destroy();
            }
            catch (e:Error) {
                trace('KyoStageCtrl: removeLayer:', e);
            }
            var ix:int = _layers.indexOf(layer);
            if (ix != -1) {
                _layers.splice(ix, 1);
            }

            if (removeBack != null) {
                removeBack();
            }
        }

    }

    /**
     * 移除全部弹出层。
     * @example
     * <listing version="3.0">
     * ctrl.removeAllLayer();
     * </listing>
     */
    public function removeAllLayer():void {
        for each(var i:IStage in _layers) {
            removeLayer(i);
        }
        _layers = [];
    }

    /**
     * 清理主场景，可选同时清层。
     * @param _removeAllLayer 是否先 <code>removeAllLayer</code>。
     * @example
     * <listing version="3.0">
     * ctrl.clean();
     * </listing>
     */
    public function clean(_removeAllLayer:Boolean = true):void {
        if (_removeAllLayer) {
            removeAllLayer();
        }
        if (_curStage) {
            _curStage.destroy();
            _mainStage.removeChild(_curStage.display);
            _curStage = null;
        }
    }

}
}
