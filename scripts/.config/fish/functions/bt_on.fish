function bt_on
    if not systemctl is-active bluetooth.service > /dev/null
        echo Turning on bluetooth...
        sudo systemctl start bluetooth.service
        bluetoothctl power on
    end
end
