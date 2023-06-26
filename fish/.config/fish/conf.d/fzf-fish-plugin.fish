# Configre the fzf.fish plugin (https://github.com/PatrickF1/fzf.fish)


# Configure the key bindings
fzf_configure_bindings \
    # Search files/directories with Ctrl+t
    --directory=\ct \
    # In a git repository - search for commits from the git log with Ctrl+g
    --git_log=\cg
    # Also has the default bindings:
    # Search command history: Ctrl+r
    # Search processes: Ctrl+Alt+p
    # Search git status: Ctrl+Alt+s

# Configure files/directories search
set fzf_fd_opts \
    # Don't use colors
    --color=never \
    # Display hidden files, but not inside .git directories
    --hidden --exclude=.git \
    # Follow symlinks to directories
    --follow
# Don't show a preview window with the file contents
set fzf_directory_opts --preview=""

# The default command history date format (mm-dd) is too strange for me
set fzf_history_time_format "%H:%M %d/%m/%y"

# The git log is actually a pretty nice way to browse git history, I want a way
# to have it full screen.
# Also if I like it, could try to add an option to the plugin where you can
# supply the git log arguments, so you can give your own revision/paths (and
# change the date format).
function gitlog_fzf
    fzf_git_log_opts="--height=100%" _fzf_search_git_log
end
