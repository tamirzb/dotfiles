function bt_connect -w "bluetoothctl connect" --argument device
    bluetoothctl power on
    bluetoothctl connect $device
end
