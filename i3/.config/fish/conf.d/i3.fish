if test -z "$DISPLAY" -a "$XDG_VTNR" = 1
    exec startx
end
