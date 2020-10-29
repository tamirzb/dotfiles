function fish_user_key_bindings
    # FZF key bindings:
    # Ctrl+T: Select files/folders (can select multiple with Tab)
    # Ctrl+R: Search in command history
    # Alt+C: Change directory
    fzf_key_bindings
    # Alt+Shift+C: Change directory backwards. Taken from fzf's wiki.
    function fzf-bcd-widget -d 'cd backwards'
        pwd | awk -v RS=/ '/\n/ {exit} {p=p $0 "/"; print p}' | tac | eval (__fzfcmd) +m --select-1 --exit-0 $FZF_BCD_OPTS | read -l result
        [ "$result" ]; and cd $result
        commandline -f repaint
    end
    bind \eC "fzf-bcd-widget"

    # Use Ctrl+X to disown a job
    bind \cx "disown 2>/dev/null && commandline -f force-repaint"
end
