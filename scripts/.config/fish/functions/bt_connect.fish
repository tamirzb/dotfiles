function bt_connect -w "bluetoothctl connect" --argument device
    if not systemctl is-active bluetooth.service > /dev/null
        echo Turning on bluetooth...
        sudo systemctl start bluetooth.service
        bluetoothctl power on
    end
    bluetoothctl connect $device
end
