function firefox
    set -x MOZ_ENABLE_WAYLAND 1
    command firefox $argv
end
