# Unless explicitly asked not to, run fish
# ref: https://wiki.archlinux.org/index.php/Fish#Modify_.bashrc_to_drop_into_fish
if [ -z "$DONT_RUN_FISH" ]; then
    exec fish
fi
