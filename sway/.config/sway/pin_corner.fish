#!/usr/bin/fish

#
# Pin the current window as a sticky (displays on all workspaces) small window
# in the corner
# Useful for videos to be played in the background
#


# Constants to define the window size and position
set WINDOW_WIDTH 355
set WINDOW_HEIGHT 200
set DISTANCE_FROM_BOTTOM 46
set DISTANCE_FROM_RIGHT 14

# Parse the width and height of the current display
set jq_query '[.[] | select(.focused == true)][0].rect'
set display_rect (swaymsg -t get_outputs | jq $jq_query)
set display_width (echo $display_rect | jq '.width')
set display_height (echo $display_rect | jq '.height')

# Calculate the required window position, relative to the display size
set pos_x (math "$display_width - ($WINDOW_WIDTH + $DISTANCE_FROM_RIGHT)")
set pos_y (math "$display_height - ($WINDOW_HEIGHT + $DISTANCE_FROM_BOTTOM)")

# Configure the window
swaymsg floating enable
# It's seems that there is a weird issue where "floating enable" takes time,
# and if the "resize" happens before the floating command is done it doesn't
# really happen. The sleep is a hacky way to take care of this.
sleep 0.1
swaymsg resize set $WINDOW_WIDTH $WINDOW_HEIGHT
swaymsg move position $pos_x $pos_y
swaymsg sticky enable
