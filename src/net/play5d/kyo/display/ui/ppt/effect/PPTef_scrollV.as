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
 * 垂直滑动切换效果，支持正向 / 反向。
 *
 * @see BasePPTEffect
 * @see #direct
 * @see PPTef_scrollH
 */
public class PPTef_scrollV extends BasePPTEffect {
    /**
     * @param direct 滑动方向：<code>1</code> 正向（上一页在上、下一页在下），<code>-1</code> 反向。
     */
    public function PPTef_scrollV(direct:int = 1) {
        super();
        this.direct = direct;
    }

    /**
     * 垂直滑动方向：1 正向，-1 反向。
     * @default 1
     */
    public var direct:int = 1;
    /** @private */
    private var _tween:TweenLite;

    /**
     * @private 按 <code>direct</code> 布置三页 Y 坐标。
     */
    protected override function initStart():void {
        _sp.y         = 0;
        _currentPic.y = 0;

        switch (direct) {
        case 1:
            _prevPic.y = -_pointer.size.y;
            _nextPic.y = _pointer.size.y;
            break;
        case -1:
            _prevPic.y = _pointer.size.y;
            _nextPic.y = -_pointer.size.y;
            break;
        }
    }

    /** @inheritDoc */
    public override function tweenNext(back:Function):void {
        switch (direct) {
        case 1:
            _tween = TweenLite.to(_sp, duration, {y: -_size.y, onComplete: back});
            break;
        case -1:
            _tween = TweenLite.to(_sp, duration, {y: _size.y, onComplete: back});
            break;
        }
    }

    /** @inheritDoc */
    public override function tweenPrev(back:Function):void {
        switch (direct) {
        case 1:
            _tween = TweenLite.to(_sp, duration, {y: _size.y, onComplete: back});
            break;
        case -1:
            _tween = TweenLite.to(_sp, duration, {y: -_size.y, onComplete: back});
            break;
        }
    }

    /** @inheritDoc */
    public override function tweenBack():void {
        var t:Number = duration / 2;
        _tween       = TweenLite.to(_sp, t, {y: 0});
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
    protected override function onDraging():void {
        _sp.y = mousePoint().y - _downP.y;
    }

    /** @inheritDoc */
    protected override function dragNext():Boolean {
        return _sp.y - _downSPP.y < -100;
    }

    /** @inheritDoc */
    protected override function dragPrev():Boolean {
        return _sp.y - _downSPP.y > 100;
    }
}
}
