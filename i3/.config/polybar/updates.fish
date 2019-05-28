#!/usr/bin/fish

# Make sure no other checkupdates is running - wait until they are all done
while pgrep -u $USER -x checkupdates >/dev/null
    sleep 1
end

set updates_arch (checkupdates | wc -l)
set updates_aur (pikaur -Qua 2> /dev/null | wc -l)

if test $updates_arch -gt 0 -o $updates_aur -gt 0
    echo "$updates_arch %{F#5b5b5b}%{F-} $updates_aur"
end
