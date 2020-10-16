function fish_user_key_bindings
    # FZF key bindings:
    # Ctrl+T: Select files/folders (can select multiple with Tab)
    # Ctrl+R: Search in command history
    # Alt+C: Change directory
    fzf_key_bindings

    # Use Ctrl+X to disown a job
    bind \cx "disown 2>/dev/null && commandline -f force-repaint"
end
