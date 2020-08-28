#!/usr/bin/fish

#
# This script checks the connection to the internet, and prints the results in
# a waybar format
#


# Print a waybar-format output
function print_output -a text tooltip class
    echo "{\"text\": \"$text\", \"tooltip\": \"$tooltip\"," \
           "\"class\": \"$class\" }"
end

# Check the connection to a given IP
# 0 -> all good, 1 -> choppy connection, 2 -> bad connection
function check_connection -a ip
    if not set ping_result (ping -w 3 $ip 2>&1)
        return 2
    else if test (count $ping_result) -ne 8
        math (count $ping_result) - 5
        return 1
    else
        return 0
    end
end


# First check the connection to the default gateway
set default_gw (ip route | awk '/default/ { print $3 }')
set default_gw_check (check_connection $default_gw)
switch $status
    case 2
        print_output "⚠" "Couldn't connect to the default gateway" "critical"
        exit
    case 1
        print_output "⚠" "Choppy connection to the default gateway\n\
Working pings: $default_gw_check/3" "warning"
        exit
end

# Now check the connection to the internet by checking Google's DNS server
set internet_check (check_connection 8.8.8.8)
switch $status
    case 2
        print_output "" "Couldn't connect to the internet" "critical"
    case 1
        print_output "" "Choppy connection to the internet\n\
Working pings: $internet_check/3" "warning"
    case 0
        print_output "" "" ""
end
