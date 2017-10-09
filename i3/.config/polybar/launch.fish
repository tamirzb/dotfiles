#!/bin/fish

killall -q polybar

# Run polybar for each monitor.
for monitor in (echo $argv | tr ' ' \n | uniq)
    set -x MONITOR $monitor
    polybar -r default &
end
