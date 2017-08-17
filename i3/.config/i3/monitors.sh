#!/bin/bash

killall -q polybar

if xrandr | grep "^DP1-1 connected" > /dev/null && \
   xrandr | grep "^DP1-2 connected" > /dev/null; then
    # External dual monitor setup
    xrandr --output eDP1 --off
    xrandr --output DP1-1 --scale 2x2 --auto
    xrandr --output DP1-2 --scale 2x2 --pos 3840x0 --auto
    MONITOR=DP1-1 polybar -r default &
    MONITOR=DP1-2 polybar -r default &
else
    # Either no external monitors or an unknown setup
    xrandr --output eDP1 --auto
    xrandr --output DP1-1 --auto
    xrandr --output DP1-2 --auto
    MONITOR=eDP1 polybar -r default &
fi

feh --bg-fill ~/.config/i3/lampard_wallpaper.jpg --no-fehbg
