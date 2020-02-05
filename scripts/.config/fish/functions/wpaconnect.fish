function wpaconnect -a ssid
    read -P "WPA Passphrase: " -l pass
    sudo wpa_supplicant -c (wpa_passphrase $ssid $pass | psub) $argv[2..-1]
end
