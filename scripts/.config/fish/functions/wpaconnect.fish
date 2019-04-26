function wpaconnect -a ssid
    read -s -P "WPA Passphrase: " -l pass
    echo sudo wpa_supplicant -c (wpa_passphrase $ssid $pass | psub) $argv[2..-1]
end
