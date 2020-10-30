function pacremove -w "pacman -R"
    set -l pkgs \
        (pacman -Qq | fzf --multi --preview 'pacman -Qi --color always {1}')
    if test -n "$pkgs"
        commandline "sudo pacman -Rs $argv $pkgs"
        commandline -f execute
    end
end
