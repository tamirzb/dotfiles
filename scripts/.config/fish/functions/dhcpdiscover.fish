function dhcpdiscover -a interface
    if test -n "$interface"
        set args -e $interface
    end
    sudo nmap --script broadcast-dhcp-discover $args
end

complete -x -c dhcpdiscover -a "(__fish_print_interfaces)"
