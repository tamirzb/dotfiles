function screen_edit
    swappy -f /tmp/screen.png -o - | tee /tmp/screen_edit.png | wl-copy
end
