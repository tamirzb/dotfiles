# Open a new terminal to update AUR packages
function update_aur
    alacritty -e fish -i -C "pikaur -Syua && pkill -SIGRTMIN+8 waybar"
end
