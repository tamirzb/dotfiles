function wireshark
    set -x QT_QPA_PLATFORM wayland
    command wireshark $argv
end
