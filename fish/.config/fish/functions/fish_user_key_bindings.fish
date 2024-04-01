function fish_user_key_bindings
    # Use Ctrl+X to disown a job
    bind \cx "disown 2>/dev/null && commandline -f force-repaint"

    # Switch copying of current command line to Alt+C (default was Ctrl+X)
    # (Default for Alt+C is to capitalize a word but it doesn't seem very
    #  useful)
    bind \ec fish_clipboard_copy
end
