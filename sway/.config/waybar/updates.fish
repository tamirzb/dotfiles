#!/usr/bin/fish

#
# This script monitors the JSON file created by arch_updates_monitor.py using
# inotify and prints the content whenever it changes.
#

set updates_file "$XDG_RUNTIME_DIR/arch_updates_monitor.json"

# Function to read and print the JSON file
function print_json_content
    if test -f $updates_file
        cat $updates_file
    else
        # File doesn't exist yet
        echo '{"text": "!", "tooltip": "Updates json file not available", "class": "error"}'
    end
end

# Print initial content
print_json_content

# Monitor the file for changes using inotifywait
# -m: monitor continuously
# -e modify: watch for file modifications
# -e create: watch for file creation (in case it doesn't exist initially)
# -e move: watch for file moves (atomic writes)
# --format '': suppress default output format
inotifywait -m -e modify -e create -e move --format '' "$updates_file" 2>/dev/null | while read
    print_json_content
end
