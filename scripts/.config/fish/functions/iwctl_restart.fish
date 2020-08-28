function iwctl_restart -a interface
    ping 8.8.8.8 &
    iwctl device $interface set-property Powered off
    iwctl device $interface set-property Powered on
    fg &> /dev/null
end
