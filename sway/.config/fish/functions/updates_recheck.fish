function updates_recheck
    # Trigger both the update monitor daemon and the script that checks if you
    # need to reboot in waybar
    pkill -f -USR1 arch_updates_monitor.py
    pkill -SIGRTMIN+8 waybar
end
