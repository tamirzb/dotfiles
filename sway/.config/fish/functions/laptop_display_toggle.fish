# This is designed to control a running instance of the
# 'manage_laptop_display.py' script. It sends a SIGUSR1 signal to it to toggle
# if it's enabled or not.

function laptop_display_toggle
    set -l pid_file "$XDG_RUNTIME_DIR/sway-manage-laptop-display.pid"

    # Check pid file exists
    if not test -e $pid_file
        echo "PID file not found in runtime directory." >&2
        return 1
    end

    set -l target_pid (cat $pid_file)

    kill -SIGUSR1 "$target_pid"

    if test $status -ne 0
        echo "Error: Failed to send signal to process $target_pid Check permissions." >&2
        return 1
    end
end
