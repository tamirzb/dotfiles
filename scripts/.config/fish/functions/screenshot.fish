function screenshot
    grim -g (slurp) /dev/stdout | tee /tmp/screen.png | wl-copy
end
