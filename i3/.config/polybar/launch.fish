#!/bin/fish

killall -q polybar

# Run polybar for each monitor.
for monitor in (printf "%s\n" $argv | uniq)
    set -x MONITOR $monitor
    polybar -r default &
end
