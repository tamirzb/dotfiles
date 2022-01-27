#!/usr/bin/fish

#
# This script cycles between languages on sway
#


# It seems that sway has many inputs which are not really a keyboard defined as
# type=keyboard, but it also seems that making one of them switch layout makes
# all of them do the same, so it's not a big deal. All we have to do is get the
# identifier of one of them and switch its layout.
# (Using "type:keyboard" here, same as in the sway config file doesn't seem to
# work. Reference: https://unix.stackexchange.com/q/571885 )
set jq_query '[.[] | select(.type == "keyboard")][0].identifier'
set input_id (swaymsg -t get_inputs | jq $jq_query)
swaymsg input $input_id xkb_switch_layout next
