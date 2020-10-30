function pacinstall -w "pacman -S"
    set -l pkgs \
        (pacman -Slq | fzf --multi --preview 'pacman -Si --color always {1}')
    if test -n "$pkgs"
        commandline "sudo pacman -S $argv $pkgs"
        commandline -f execute
    end
end
