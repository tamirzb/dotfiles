#!/usr/bin/fish

#
# This script gets the number of Arch and AUR package updates available, and
# prints the results in a waybar format
#


# Print a waybar-format output
function print_output -a text tooltip class
    echo "{\"text\": \"$text\", \"tooltip\": \"$tooltip\"," \
           "\"class\": \"$class\" }"
end

# Print the result of an updates check
function print_updates -a arch aur
    if test $arch -gt 0
        set class "arch"
        set tooltip "Arch updates: $arch"
    end
    if test $aur -gt 0
        set -a class "aur"
        set -a tooltip "AUR updates: $aur"
    end

    if test -z "$class"
        print_output "" \
                     "No updates found\nLast checked: "(date +"%H:%M") \
                     "none"
    else
        print_output "" (string join "\n" $tooltip) (string join "_" $class)
    end
end


# If we don't have an internet connection, wait until we do
while not ping -q -w 2 -c 1 8.8.8.8 &> /dev/null
    print_output "" "" ""
    sleep 20
end


# Unfortunately waybar executes this script once per output, so we need to make
# sure we only actually check updates once. We do this by having the main
# instance of the script (first one, who actually does the update checking)
# lock a file via flock, and then when it's done the other instances can just
# read that file.
set updates_file /tmp/waybar_updates-(id -u)
set lock_file "$updates_file".lock


print_output  "Checking updates..." loading

begin
    # Try to obtain the lock. If it fails, it means another instance is already
    # checking updates
    if flock -n 9
        # No other instance is running, check for updates ourselves
        set updates_arch (checkupdates | wc -l)
        set updates_aur (pikaur -Qua 2> /dev/null | wc -l)
        print_updates $updates_arch $updates_aur | tee $updates_file
    else
        # Another instance is running, wait for it to finish then read its
        # result
        flock 9
        cat $updates_file
    end
end 9>$lock_file
