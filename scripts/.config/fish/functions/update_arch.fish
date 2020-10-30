function update_arch
    sudo pacman -Syu && pkill -SIGRTMIN+8 waybar
end
