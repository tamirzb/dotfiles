# Open a new terminal to update Arch packages
function update_arch
    alacritty -e fish -i -C "sudo pacman -Syu && pkill -SIGRTMIN+8 waybar"
end
