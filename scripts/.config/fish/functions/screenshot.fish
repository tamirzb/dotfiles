function screenshot
    grim -g (_select_region) - | tee /tmp/screen.png | wl-copy
end
