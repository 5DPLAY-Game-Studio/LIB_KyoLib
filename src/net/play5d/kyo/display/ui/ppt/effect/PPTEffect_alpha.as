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
 * 淡入淡出切换效果：邻页从透明渐显。
 *
 * @see BasePPTEffect
 * @see #tweenNext()
 * @see #tweenPrev()
 */
public class PPTEffect_alpha extends BasePPTEffect {
    /**
     * 构造淡入淡出效果。
     */

    /** @private 当前过渡 Tween */
    private var _tween:TweenLite;

    /**
     * @private 当前页不透明，邻页透明。
     */
    protected override function initStart():void {
        _prevPic.alpha    = 0;
        _nextPic.alpha    = 0;
        _currentPic.alpha = 1;
    }

    /** @inheritDoc */
    public override function tweenNext(back:Function):void {
        _tween = TweenLite.to(_nextPic, duration, {alpha: 1, onComplete: back});
    }

    /** @inheritDoc */
    public override function tweenPrev(back:Function):void {
        _tween = TweenLite.to(_prevPic, duration, {alpha: 1, onComplete: back});
    }

    /** @inheritDoc */
    public override function tweenBack():void {
        _tween = TweenLite.to(_sp, duration / 2, {alpha: 1});
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

}
}
