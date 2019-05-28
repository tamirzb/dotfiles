#!/bin/fish

killall -q polybar

if xgetres i3wm.monitor
    # Single monitor setup
    polybar -r default &
else
    # Dual-monitor setup
    polybar -r left &
    polybar -r right &
end
