#!/bin/fish

killall -q polybar

# Local script in charge of setting up the monitors and returning them.
set monitors (eval $HOME/.monitors)

# If there are multiple monitors then assign each one to half the workspaces.
if [ (count $monitors) = 2 ]
    i3-msg workspace (seq 1 5) output $monitors[1]
    i3-msg workspace (seq 6 10) output $monitors[2]
end

# Run polybar for each monitor.
for monitor in $monitors
    set -x MONITOR $monitor
    polybar -r default &
end

feh --bg-fill $HOME/.config/i3/lampard_wallpaper.jpg --no-fehbg
