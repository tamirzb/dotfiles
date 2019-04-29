if test -z "$DISPLAY" -a -n "$XDG_VTNR"; and test $XDG_VTNR = 1
    exec startx
end
