# Change background color to strongly differentiate between SSH and local
# terminals

function ssh
    function set_term_bgcolor -a color
        echo -ne "\\033]11;$color\\007"
    end

    set_term_bgcolor "#020821"
    command ssh $argv
    set_term_bgcolor "#1d1f21"
end
