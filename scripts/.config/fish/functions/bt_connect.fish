function bt_connect -w "bluetoothctl connect" --argument device
    bt_on
    bluetoothctl connect $device
end
