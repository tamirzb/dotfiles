function swaylock
    # Switch keyboard to English before locking
    swaymsg input type:keyboard xkb_switch_layout 0
    command swaylock $argv
end
