# Change background color to strongly differentiate between SSH and local
# terminals

# This file is both sourced by fish (to get the ssh function) but can be
# executed by fish as well. This is because it needs to trap SIGINT and for
# some reason that works in executed files but not in functions (ref:
# https://github.com/fish-shell/fish-shell/issues/6649#issuecomment-1198951287)

if status --is-interactive
    function ssh
        fish (status filename) $argv
    end
else
    function set_term_bgcolor -a color
        echo -ne "\\033]11;$color\\007"
    end

    # Use trap to make sure resetting background color always happens (on exit
    # but also on Ctrl+C)
    trap 'set_term_bgcolor "#1d1f21"' EXIT INT
    set_term_bgcolor "#020821"
    command ssh $argv
end
