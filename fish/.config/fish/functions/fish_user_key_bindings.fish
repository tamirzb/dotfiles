function fish_user_key_bindings
    # FZF key bindings:
    # Ctrl+T: Select files/folders (can select multiple with Tab)
    # Ctrl+R: Search in command history
    # Alt+C: Change directory
    fzf_key_bindings

    # Alt+Shift+C: Change directory backwards. Based on fzf's and other fzf
    # keybindings.
    function fzf-bcd-widget -d 'cd backwards'
        test -n "$FZF_TMUX_HEIGHT"; or set FZF_TMUX_HEIGHT 40%
        begin
            set -lx FZF_DEFAULT_OPTS "--height $FZF_TMUX_HEIGHT --reverse $FZF_DEFAULT_OPTS $FZF_BCD_OPTS"
            pwd | awk -v RS=/ '/\n/ {exit} {p=p $0 "/"; print p}' | tac | \
                eval (__fzfcmd) +m --select-1 --exit-0 | read -l result
            [ "$result" ]; and cd $result
        end
        commandline -f repaint
    end
    bind \eC "fzf-bcd-widget"

    # Use Ctrl+X to disown a job
    bind \cx "disown 2>/dev/null && commandline -f force-repaint"
end
