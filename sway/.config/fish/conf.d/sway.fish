# Autostart sway on tty1
if test -z "$DISPLAY" -a "$XDG_VTNR" = 1
    set -x XDG_SESSION_TYPE wayland
    exec sway
end
