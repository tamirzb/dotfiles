function updates_recheck
    # Trigger both the update monitor daemon and the script that checks if you
    # need to reboot in waybar
    pkill -f -USR1 "python -m monitor"
    pkill -SIGRTMIN+8 waybar
end
