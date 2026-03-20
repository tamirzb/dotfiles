#!/usr/bin/env fish

# Change background color to strongly differentiate between SSH and local

function set_term_bgcolor -a color
    if test -t 1
        echo -ne "\033]11;$color\007"
    end
end

trap 'set_term_bgcolor "#1d1f21"' EXIT INT
set_term_bgcolor "#020821"
command ssh $argv
