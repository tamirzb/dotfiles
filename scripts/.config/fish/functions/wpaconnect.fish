function wpaconnect -a ssid
    read -i -P "WPA Passphrase: " -l pass
    sudo wpa_supplicant -c (wpa_passphrase $ssid $pass | psub) $argv[2..-1]
end
