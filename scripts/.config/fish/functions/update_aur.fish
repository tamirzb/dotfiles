function update_aur
    pikaur -Syua && pkill -SIGRTMIN+8 waybar
end
