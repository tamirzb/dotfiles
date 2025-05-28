function scrcpy
    # Based on https://github.com/Genymobile/scrcpy/blob/master/FAQ.md#issue-with-wayland
    set -x SDL_VIDEODRIVER wayland
    command scrcpy $argv
end
