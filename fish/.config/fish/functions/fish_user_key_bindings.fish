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

    # Alt+Shift+T: Like Ctrl+T, but including hidden files
    function fzf-all-file-widget -d "List files and folders, including hidden"
        set -l commandline (__fzf_parse_commandline)
        set -l dir $commandline[1]
        set -x FZF_CTRL_T_COMMAND "
        command find -L \$dir -mindepth 1 \\( -fstype 'sysfs' -o -fstype 'devfs' -o -fstype 'devtmpfs' \\) -prune \
        -o -type f -print \
        -o -type d -print \
        -o -type l -print 2> /dev/null | sed 's@^\./@@'"
        fzf-file-widget
    end
    bind \eT "fzf-all-file-widget"

    # Use Ctrl+X to disown a job
    bind \cx "disown 2>/dev/null && commandline -f force-repaint"
end
