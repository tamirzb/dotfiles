# Select a region on the screen
# By default allows choosing between inner areas of visible windows

function _select_region
    swaymsg -t get_tree | \
        jq -r '.. | select(.pid? and .visible?) | "\(.rect.x + .window_rect.x),\(.rect.y + .window_rect.y) \(.window_rect.width)x\(.window_rect.height)"' | \
        slurp
end
