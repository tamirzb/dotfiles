# Autostart sway on tty1
if test -z "$DISPLAY" -a "$XDG_VTNR" = 1
    sway
end
