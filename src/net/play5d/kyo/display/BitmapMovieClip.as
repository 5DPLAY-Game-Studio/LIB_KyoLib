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
import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.events.Event;
import flash.geom.ColorTransform;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;

/**
 * 将 MovieClip 或位图帧序列逐帧烘焙为 BitmapData 并播放的 Sprite。
 *
 * <p>支持单 MC 绘制、多层 MC 合成绘制，以及帧脚本与标签跳转。</p>
 *
 * @see BitmapMCFrameVO
 * @example
 * <listing version="3.0">
 * var bmc:BitmapMovieClip = new BitmapMovieClip();
 * bmc.draw(mc);
 * bmc.play();
 * </listing>
 */
public class BitmapMovieClip extends Sprite {
    /**
     * 构造位图影片剪辑。
     *
     * @param autoPlay 是否自动播放，默认 <code>true</code>。
     * @param drawFrames 最大绘制帧数；MC 超过此值则不创建后续帧，<code>-1</code> 表示不限制。
     * @param lockSize 绘制时若 Matrix 含缩放，是否锁定宽高（将 matrix 的 <code>a</code>/<code>d</code> 置为 1），默认 <code>false</code>。
     */
    public function BitmapMovieClip(autoPlay:Boolean = true, drawFrames:int = -1, lockSize:Boolean = false) {
        this.autoPlay = autoPlay;
        this.lockSize = lockSize;
        _maxFrames    = drawFrames;
    }

    /**
     * 当前播放帧号（从 1 起）。
     * @default 0
     */
    public var currentFrame:int;
    /**
     * 当前帧标签。
     * @default null
     */
    public var currentFrameLabel:String;
    /**
     * 总帧数（<code>insArray</code> 有效长度减 1）。
     * @default 0
     */
    public var totalFrames:int;
    /**
     * 每帧之间的间隔帧数（<code>renderNextFrame</code> 计数用）。
     * @default 0
     */
    public var gapFrame:int;
    /**
     * 播放到末尾后，再经过多少间隔帧才循环或结束。
     * @default 0
     */
    public var loopGapFrame:int;
    /**
     * 绘制时是否锁定源对象宽高（见构造参数 <code>lockSize</code>）。
     */
    public var lockSize:Boolean;
    /**
     * 初始化完成后是否自动播放。
     */
    public var autoPlay:Boolean;
    /**
     * 绘制前是否按 bounds 修正注册点。
     * @default true
     */
    public var fixRegPoint:Boolean   = true;
    /**
     * 固定每帧 BitmapData 尺寸；为 <code>null</code> 时使用绘制结果尺寸。
     * @default null
     */
    public var fixSize:Point;
    /**
     * 播放到末尾后是否循环。
     * @default true
     */
    public var loopPlay:Boolean      = true;
    /**
     * 非循环模式下是否已播放完成。
     * @default false
     */
    public var playComplete:Boolean;
    /**
     * 绘制时附加的偏移量。
     * @default null
     */
    public var fixPoint:Point;
    /**
     * 非循环播放完成时的回调。
     * @default null
     */
    public var onPlayComplete:Function;
    /** @private 显示用 Bitmap 子对象 */
    protected var _bp:Bitmap;
    /** @private 帧号到脚本列表的映射 */
    private var _scripts:Object;
    /** @private 最大绘制帧数 */
    private var _maxFrames:int;
    /** @private 当前间隔帧计数 */
    private var _currentGapFrame:int = 0;
    /** @private MC 上待监听的函数数组属性名列表 */
    private var _listenFunctions:Array;
    /** @private 帧数据数组，索引 1 起为有效帧 */
    private var _insArray:Array;

    /**
     * 帧数据数组；赋值后将据此初始化并可选自动播放。
     *
     * @return <code>BitmapMCFrameVO</code> 数组，索引 1 起为帧数据。
     * @see BitmapMCFrameVO
     */
    public function get insArray():Array {
        return _insArray;
    }

    /** @private */
    public function set insArray(value:Array):void {
        if (!value) {
            return;
        }
        _insArray = value;
        initBMC();
    }

    /** @private */
    public function set bitmapDataArray(value:Array):void {
        if (!value) {
            return;
        }
        var f:int;
        _insArray = [];
        for each(var i:BitmapData in value) {
            f++;
            var vo:BitmapMCFrameVO = new BitmapMCFrameVO();
            vo.bd                  = i;
            _insArray[f]           = vo;
        }
        initBMC();
    }

    /**
     * 将单个 DisplayObject（通常为 MovieClip）逐帧绘制为 BitmapData 序列。
     *
     * @param source 源显示对象；为 MovieClip 时按总帧数逐帧绘制，否则只绘一帧。
     * @param matrix 可选变换矩阵，缩放会乘到 <code>source.scaleX/Y</code>。
     * @param colorTransform 可选颜色变换。
     * @param blendMode 可选混合模式。
     * @param clipRect 可选裁剪矩形。
     * @param smoothing 是否平滑缩放。
     * @see #drawMulti()
     * @example
     * <listing version="3.0">
     * bmc.draw(mc);
     * </listing>
     */
    public function draw(
        source        :DisplayObject,
        matrix        :Matrix = null,
        colorTransform:ColorTransform = null,
        blendMode     :String = null,
        clipRect      :Rectangle = null,
        smoothing     :Boolean = false
    ):void {
        beforeDraw(matrix, colorTransform, blendMode, clipRect, smoothing);
        var drawVar:DrawVar = new DrawVar(source, matrix, colorTransform, blendMode, clipRect, smoothing);
        if (drawVar.source is MovieClip) {
            var mc:MovieClip = drawVar.source as MovieClip;
            var e:int        = _maxFrames == -1 ? mc.totalFrames : Math.min(_maxFrames, mc.totalFrames);
            for (var i:int = 1; i <= e; i++) {
                createFrame(drawVar, i);
            }
        }
        else {
            createFrame(drawVar, 1);
        }
        drawVar.destroy();
        drawVar = null;
        initBMC();
    }

    /**
     * 将多个 MovieClip 按帧合成绘制为 BitmapData 序列。
     *
     * <p>可指定基帧 MC 决定总帧数与帧标签；超出基帧帧数的层可隐藏。</p>
     *
     * @param source MovieClip 或其它 DisplayObject 数组。
     * @param matrix 可选变换矩阵。
     * @param colorTransform 可选颜色变换。
     * @param blendMode 可选混合模式。
     * @param clipRect 可选裁剪矩形。
     * @param smoothing 是否平滑缩放。
     * @param baseFrameMc 基帧 MC，总帧数与标签以其为准。
     * @param hideFrameout 帧数不足的层是否隐藏，默认 <code>true</code>。
     * @see #draw()
     * @example
     * <listing version="3.0">
     * bmc.drawMulti([bodyMc, effectMc], null, null, null, null, false, bodyMc);
     * </listing>
     */
    public function drawMulti(
        source        :Array,
        matrix        :Matrix = null,
        colorTransform:ColorTransform = null,
        blendMode     :String = null,
        clipRect      :Rectangle = null,
        smoothing     :Boolean = false,
        baseFrameMc   :MovieClip = null,
        hideFrameout  :Boolean = true
    ):void {
        beforeDraw(matrix, colorTransform, blendMode, clipRect, smoothing);
        var mcGroup:McGroup = new McGroup(source, baseFrameMc, hideFrameout);
        var drawVar:DrawVar = new DrawVar(mcGroup, matrix, colorTransform, blendMode, clipRect, smoothing);
        var e:int           = _maxFrames == -1 ? mcGroup.totalFrames : Math.min(_maxFrames, mcGroup.totalFrames);
        for (var i:int = 1; i <= e; i++) {
            createFrame(drawVar, i);
        }
        mcGroup.destroy();
        mcGroup = null;
        drawVar.destroy();
        drawVar = null;
        initBMC();
    }

    /**
     * 克隆实例，共享同一 <code>insArray</code> 帧数据。
     *
     * @return 新实例，未自动播放。
     * @example
     * <listing version="3.0">
     * var copy:BitmapMovieClip = bmc.clone();
     * </listing>
     */
    public function clone():BitmapMovieClip {
        var bmc:BitmapMovieClip = new BitmapMovieClip();
        bmc.insArray            = _insArray;
        return bmc;
    }

    /**
     * 跳转到指定帧并开始播放。
     *
     * @param frame 帧号（<code>int</code>）或帧标签（<code>String</code>）。
     * @param scene 未使用，保留以兼容 MovieClip API。
     * @see #gotoAndStop()
     * @example
     * <listing version="3.0">
     * bmc.gotoAndPlay(3);
     * bmc.gotoAndPlay('attack');
     * </listing>
     */
    public function gotoAndPlay(frame:Object, scene:String = null):void {
        var f:int = getFrame(frame);
        if (f > 0) {
            currentFrame = f;
        }
        play();
    }

    /**
     * 跳转到指定帧并停止。
     *
     * @param frame 帧号或帧标签。
     * @see #gotoAndPlay()
     * @example
     * <listing version="3.0">
     * bmc.gotoAndStop('idle');
     * </listing>
     */
    public function gotoAndStop(frame:Object):void {
        var f:int = getFrame(frame);
        removeEventListener(Event.ENTER_FRAME, playing);
        if (currentFrame == f || f < 1) {
            return;
        }
        if (f > totalFrames) {
            frame = totalFrames;
        }
        currentFrame = f;
        render();
    }

    /**
     * 前进一帧并停止。
     *
     * @example
     * <listing version="3.0">
     * bmc.nextFrame();
     * </listing>
     */
    public function nextFrame():void {
        stop();
        playComplete = false;
        currentFrame++;
        render();
    }

    /**
     * 后退一帧并停止。
     *
     * @example
     * <listing version="3.0">
     * bmc.prevFrame();
     * </listing>
     */
    public function prevFrame():void {
        stop();
        playComplete = false;
        currentFrame--;
        render();
    }

    /**
     * 开始按 ENTER_FRAME 播放（总帧数小于 2 时不播放）。
     *
     * @see #stop()
     * @example
     * <listing version="3.0">
     * bmc.play();
     * </listing>
     */
    public function play():void {
        if (totalFrames < 2) {
            return;
        }
        if (hasEventListener(Event.ENTER_FRAME)) {
            return;
        }
        addEventListener(Event.ENTER_FRAME, playing);
    }

    /**
     * 停止播放并移除 ENTER_FRAME 监听。
     *
     * @see #play()
     * @example
     * <listing version="3.0">
     * bmc.stop();
     * </listing>
     */
    public function stop():void {
        removeEventListener(Event.ENTER_FRAME, playing);
    }

    /**
     * 在指定帧注册回调脚本。
     *
     * @param frame 帧号。
     * @param script 回调函数。
     * @param params 传给回调的参数数组，默认 <code>null</code>。
     * @example
     * <listing version="3.0">
     * bmc.addFrameScript(5, onHit, [target]);
     * </listing>
     */
    public function addFrameScript(frame:int, script:Function, params:Array = null):void {
        var insf:InsFunction = new InsFunction(script, params);

        _scripts ||= {};
        _scripts[frame] ||= [];
        KyoArrayUtils.pushIfAbsent(_scripts[frame], insf);
    }

    /**
     * 注册 MC 上函数数组属性的名称，绘制时从源 MC 提取并在对应帧调用。
     *
     * <p>源 MC 中声明同名 Array，在需触发的帧赋值；元素可为 <code>Function</code> 或
     * <code>{f:Function, p:Array}</code>。</p>
     *
     * @param name MC 上 Array 类型属性名。
     * @example
     * <listing version="3.0">
     * bmc.addFunctionListener('frameCalls');
     * </listing>
     */
    public function addFunctionListener(name:String):void {
        KyoArrayUtils.pushIfAbsent(_listenFunctions, name);
    }

    /**
     * 按 <code>gapFrame</code> 间隔推进一帧（ENTER_FRAME 回调内部使用）。
     *
     * @see #gapFrame
     */
    public function renderNextFrame():void {
        if (_currentGapFrame == 0) {
            _currentGapFrame = gapFrame;
            currentFrame++;
            playComplete = false;
            render();
        }
        else {
            _currentGapFrame--;
        }
    }

    /**
     * 停止播放并释放资源。
     *
     * @param clearBitmap 为 <code>true</code> 时 dispose 各帧 BitmapData。
     * @example
     * <listing version="3.0">
     * bmc.destroy(true);
     * </listing>
     */
    public function destroy(clearBitmap:Boolean = false):void {
        stop();
        if (clearBitmap) {
            for each(var i:BitmapMCFrameVO in _insArray) {
                if (i.bd) {
                    i.bd.dispose();
                }
                i = null;
            }
        }
        _insArray = null;
    }

    /** @private 根据 insArray 初始化显示与播放状态 */
    private function initBMC():void {
        if (!_insArray || _insArray.length < 1) {
            throw Error('bitMapDatas has no data');
        }
        if (!_bp) {
            _bp = new Bitmap();
            addChild(_bp);
        }
        playComplete = false;
        currentFrame = 1;
        totalFrames  = _insArray.length - 1;
        render();
        if (autoPlay) {
            play();
        }
    }

    /** @private 绘制单帧并写入 insArray */
    private function createFrame(drawVar:DrawVar, frame:int):void {
        var sc:DisplayObject = drawVar.source;
        var mc:MovieClip     = sc is MovieClip ? sc as MovieClip : null;
        var gmc:McGroup      = sc is McGroup ? sc as McGroup : null;

        var ins:BitmapMCFrameVO = new BitmapMCFrameVO();

        if (mc) {
            mc.gotoAndStop(frame);
            initListenFunctions(mc, frame);
            ins.frameLabel = mc.currentFrameLabel;
        }
        if (gmc) {
            gmc.gotoAndStop(frame);
            initListenFunctions(gmc, frame);
            ins.frameLabel = gmc.currentFrameLabel;
        }

        var sp:Sprite = new Sprite();

        if (fixRegPoint) {
            var bounds:Rectangle = sc.getBounds(sc);
            sc.x                 = -(bounds.x * sc.scaleX) << 0;
            sc.y                 = -(bounds.y * sc.scaleY) << 0;
        }

        if (fixPoint) {
            sc.x += fixPoint.x;
        }

        sp.addChild(sc);

        ins.x = sc.x;
        ins.y = sc.y;

        var size:Point = fixSize ? fixSize : new Point(sp.width, sp.height);

        if (size.x > 0 && size.y > 0) {
            if (fixPoint) {
                size.x += fixPoint.x;
                size.y += fixPoint.y;
            }

            ins.bd = new BitmapData(size.x, size.y, true, 0);
            ins.bd.draw(sp, null, drawVar.colorTransform, drawVar.blendMode, drawVar.clipRect, drawVar.smoothing);
        }
        _insArray[frame] = ins;
        sp               = null;
    }

    /** @private 按 currentFrame 更新位图显示与帧脚本 */
    private function render():void {
        if (!_insArray) {
            return;
        }

        if (currentFrame > totalFrames) {
            if (currentFrame - totalFrames > loopGapFrame) {
                if (loopPlay) {
                    currentFrame = 1;
                }
                else {
                    playComplete = true;
                    if (onPlayComplete != null) {
                        onPlayComplete();
                    }
                    stop();
                    return;
                }
            }
            else {
                return;
            }
        }
        if (currentFrame < 1) {
            currentFrame = totalFrames;
        }
        var ins:BitmapMCFrameVO = _insArray[currentFrame];
        currentFrameLabel       = ins.frameLabel;
        _bp.bitmapData          = ins.bd;
        _bp.x                   = -ins.x;
        _bp.y                   = -ins.y;

        renderScript();
    }

    /** @private 执行当前帧已注册脚本 */
    private function renderScript():void {
        if (_scripts && _scripts[currentFrame] != null) {
            for each(var o:Object in _scripts[currentFrame]) {
                if (o is Function) {
                    o();
                }
                else {
                    (o.fun as Function).call(null, o.params);
                }
            }
        }
    }

    /** @private 解析帧号或帧标签 */
    private function getFrame(frame:Object):int {
        playComplete = false;

        if (frame is String) {
            for (var i:int = 1; i <= totalFrames; i++) {
                if (_insArray[i].frameLabel == frame) {
                    return i;
                }
            }
        }
        if (frame is int) {
            return frame as int;
        }
        return -1;
    }

    /** @private 绘制前重置 insArray 并处理 lockSize */
    private function beforeDraw(
        matrix        :Matrix = null,
        colorTransform:ColorTransform = null,
        blendMode     :String = null,
        clipRect      :Rectangle = null,
        smoothing     :Boolean = false
    ):void {
        _insArray = [];
        if (lockSize && matrix) {
            matrix.a = 1;
            matrix.d = 1;
        }
    }

    /** @private 从 MC 或 McGroup 提取帧函数并注册 */
    private function initListenFunctions(mc:Object, frame:int):void {
        if (!_listenFunctions) {
            return;
        }

        var fs:Array = [];
        var oo:Object;
        for each(var n:String in _listenFunctions) {
            if (mc is MovieClip) {
                var mm:MovieClip = mc as MovieClip;
                if (mm[n]) {
                    for each(var ff:Object in mm[n]) {
                        fs.push(ff);
                    }
                }
            }
            if (mc is McGroup) {
                var gmc:McGroup = mc as McGroup;
                fs              = gmc.getFrameFunctions(n);
            }
        }
        for each(var f:Object in fs) {
            if (f is Function) {
                addFrameScript(frame, f as Function);
            }
            else {
                addFrameScript(frame, f.f, f.p);
            }
        }
    }

    /** @private ENTER_FRAME 播放回调 */
    private function playing(e:Event):void {
        renderNextFrame();
    }
}
}

import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.geom.ColorTransform;
import flash.geom.Matrix;
import flash.geom.Rectangle;

import net.play5d.kyo.utils.KyoDisplayUtils;
import net.play5d.kyo.utils.KyoArrayUtils;
/**
 * 单次绘制上下文：源对象与 draw 参数。
 *
 * @private
 */
internal class DrawVar {
    /**
     * @param source 待绘制源。
     * @param matrix 可选变换矩阵。
     * @param colorTransform 可选颜色变换。
     * @param blendMode 可选混合模式。
     * @param clipRect 可选裁剪矩形。
     * @param smoothing 是否平滑。
     */
    public function DrawVar(
        source        :DisplayObject,
        matrix        :Matrix = null,
        colorTransform:ColorTransform = null,
        blendMode     :String = null,
        clipRect      :Rectangle = null,
        smoothing     :Boolean = false
    ) {
        this.source         = source;
        this.matrix         = matrix;
        this.colorTransform = colorTransform;
        this.blendMode      = blendMode;
        this.clipRect       = clipRect;
        this.smoothing      = smoothing;
        initlize();
    }

    /** @private 绘制源 DisplayObject */
    public var source:DisplayObject;
    /** @private 变换矩阵 */
    public var matrix:Matrix = null;
    /** @private 颜色变换 */
    public var colorTransform:ColorTransform = null;
    /** @private 混合模式 */
    public var blendMode:String = null;
    /** @private 裁剪矩形 */
    public var clipRect:Rectangle = null;
    /** @private 是否平滑缩放 */
    public var smoothing:Boolean = false;

    /** @private 复位源 MC 并清空引用 */
    public function destroy():void {
        if (source is MovieClip) {
            (source as MovieClip).gotoAndStop(1);
        }
        source         = null;
        matrix         = null;
        colorTransform = null;
        clipRect       = null;
    }

    /** @private 将 matrix 缩放应用到 source */
    private function initlize():void {
        if (matrix) {
            source.scaleX *= matrix.a;
            source.scaleY *= matrix.d;
        }
    }
}

/**
 * 多 MovieClip 合成容器，供 <code>drawMulti</code> 逐帧对齐。
 *
 * @private
 */
internal class McGroup extends Sprite {
    /**
     * @param mcs 待合成层列表。
     * @param baseFrameMc 基帧 MC，决定总帧数。
     * @param hideFrameout 帧数不足时是否隐藏该层。
     */
    public function McGroup(mcs:Array, baseFrameMc:MovieClip = null, hideFrameout:Boolean = true) {
        this.hideFrameout = hideFrameout;
        _baseMc           = baseFrameMc;

        var countFrame:Boolean = true;

        if (baseFrameMc) {
            totalFrames = baseFrameMc.totalFrames;
            countFrame  = false;
        }
        for (var i:int; i < mcs.length; i++) {
            var d:DisplayObject = mcs[i] as DisplayObject;
            if (!d) {
                continue;
            }
            addDisplay(d);
            if (!countFrame) {
                continue;
            }
            if (d is MovieClip) {
                (d as MovieClip).gotoAndStop(1);
                var tf:int = (d as MovieClip).totalFrames;
                if (totalFrames < tf) {
                    totalFrames = tf;
                }
            }
        }
    }

    /** @private 合成总帧数 */
    public var totalFrames:int;
    /** @private 是否隐藏超出帧数的层 */
    public var hideFrameout:Boolean;
    /** @private 子层列表 */
    private var _ins:Array = [];
    /** @private 基帧 MC */
    private var _baseMc:MovieClip;

    /**
     * @private 优先返回基帧标签，否则返回首个非基 MC 的帧标签。
     * @return 帧标签或 <code>null</code>。
     */
    public function get currentFrameLabel():String {
        if (_baseMc) {
            if (_baseMc.currentFrameLabel) {
                return _baseMc.currentFrameLabel;
            }
        }
        for each(var d:DisplayObject in _ins) {
            if (!d is MovieClip) {
                continue;
            }
            if (d == _baseMc) {
                continue;
            }
            var mc:MovieClip = d as MovieClip;
            if (mc.currentFrameLabel) {
                return mc.currentFrameLabel;
            }
        }
        return null;
    }

    /**
     * @private 添加一层到合成容器。
     * @param d 待添加显示对象。
     */
    public function addDisplay(d:DisplayObject):void {
        addChild(d);
        _ins.push(d);
    }

    /**
     * @private 各层同步跳转到指定帧。
     * @param frame 帧号。
     */
    public function gotoAndStop(frame:int):void {
        for each(var d:DisplayObject in _ins) {
            if (d is MovieClip) {
                var mc:MovieClip = d as MovieClip;
                if (mc.totalFrames >= frame) {
                    mc.visible = true;
                    mc.gotoAndStop(frame);
                    continue;
                }
            }
            if (hideFrameout) {
                d.visible = false;
            }
        }
    }

    /**
     * @private 收集各层指定名称的帧函数数组并清空源属性。
     * @param name 帧函数属性名。
     * @return <code>Function</code> 数组。
     */
    public function getFrameFunctions(name:String):Array {
        var fs:Array = [];
        for each(var d:DisplayObject in _ins) {
            if (d[name]) {
                for each(var f:Function in d[name]) {
                    fs.push(f);
                }
                d[name] = null;
            }
        }
        return fs;
    }

    /** @private 移除所有子对象 */
    public function destroy():void {
        KyoDisplayUtils.removeAllChildren(this);
        _ins = null;
    }
}

/**
 * 帧脚本封装：函数与参数。
 *
 * @private
 */
internal class InsFunction {
    /**
     * @param fun 回调函数。
     * @param params 参数数组。
     */
    public function InsFunction(fun:Function, params:Array = null) {
        _fun    = fun;
        _params = params;
    }

    /** @private */
    private var _fun:Function;
    /** @private */
    private var _params:Array;

    /** @private 调用注册的函数 */
    public function call():void {
        _fun.call(null, _params);
    }
}
