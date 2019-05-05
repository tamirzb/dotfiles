function screenshot -w maim
    maim $argv | tee /tmp/screen.png | xclip -selection clipboard -t image/png -i
end
