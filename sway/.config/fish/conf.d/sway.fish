# Autostart sway on tty1
if test -z "$DISPLAY" -a "$XDG_VTNR" = 1
    # Execute Firefox in Wayland
    set -x MOZ_ENABLE_WAYLAND 1
    # Execute some QT apps (e.g. Wireshark) in Wayland
    set -x QT_QPA_PLATFORM wayland

    set -x XDG_SESSION_TYPE wayland
    systemd-cat --stderr-priority=warning sway
end
