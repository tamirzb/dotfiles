# Automatically update the current timezone
# Based on
# https://wiki.archlinux.org/title/System_time#Update_timezone_every_time_NetworkManager_connects_to_a_network
function timezone_update
    sudo timedatectl set-timezone (curl --fail https://ipapi.co/timezone)
end
