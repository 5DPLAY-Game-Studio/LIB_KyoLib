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

package net.play5d.kyo.display.ui.ppt.effect {
import com.greensock.TweenLite;

/**
 * 水平滑动切换效果，支持正向 / 反向。
 *
 * @see BasePPTEffect
 * @see #direct
 * @see PPTef_scrollV
 */
public class PPTef_scrollH extends BasePPTEffect {
    /**
     * @param direct 滑动方向：<code>1</code> 正向（上一页在左、下一页在右），<code>-1</code> 反向。
     */
    public function PPTef_scrollH(direct:int = 1) {
        super();
        this.direct = direct;
    }

    /**
     * 水平滑动方向：1 正向，-1 反向。
     * @default 1
     */
    public var direct:int = 1;
    /** @private 当前过渡 Tween */
    private var _tween:TweenLite;

    /**
     * @private 按 <code>direct</code> 布置三页 X 坐标。
     */
    protected override function initStart():void {
        _sp.x         = 0;
        _currentPic.x = 0;

        switch (direct) {
        case 1:
            _prevPic.x = -_pointer.size.x;
            _nextPic.x = _pointer.size.x;
            break;
        case -1:
            _prevPic.x = _pointer.size.x;
            _nextPic.x = -_pointer.size.x;
            break;
        }
    }

    /** @inheritDoc */
    public override function tweenNext(back:Function):void {
        switch (direct) {
        case 1:
            _tween = TweenLite.to(_sp, duration, {x: -_size.x, onComplete: back});
            break;
        case -1:
            _tween = TweenLite.to(_sp, duration, {x: _size.x, onComplete: back});
            break;
        }
    }

    /** @inheritDoc */
    public override function tweenPrev(back:Function):void {
        switch (direct) {
        case 1:
            _tween = TweenLite.to(_sp, duration, {x: _size.x, onComplete: back});
            break;
        case -1:
            _tween = TweenLite.to(_sp, duration, {x: -_size.x, onComplete: back});
            break;
        }
    }

    /** @inheritDoc */
    public override function tweenBack():void {
        _tween = TweenLite.to(_sp, duration / 2, {x: 0});
    }

    /** @inheritDoc */
    public override function tweening():Boolean {
        return _tween && _tween._active;
    }

    /** @inheritDoc */
    public override function tweenStop():void {
        if (_tween) {
            _tween.kill();
        }
    }

    /** @inheritDoc */
    protected override function onDragging():void {
        _sp.x = mousePoint().x - _downP.x;
    }

    /** @inheritDoc */
    protected override function dragNext():Boolean {
        return _sp.x - _downSPP.x < -100;
    }

    /** @inheritDoc */
    protected override function dragPrev():Boolean {
        return _sp.x - _downSPP.x > 100;
    }
}
}
