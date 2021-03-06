function sway
    # Execute Firefox in Wayland
    set -x MOZ_ENABLE_WAYLAND 1
    # Execute some QT apps (e.g. Wireshark) in Wayland
    set -x QT_QPA_PLATFORM wayland

    set -x XDG_SESSION_TYPE wayland
    systemd-cat --stderr-priority=warning -t sway sway $argv
end
