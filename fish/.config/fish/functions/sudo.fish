function sudo -w sudo
    # Handle fish functions: If argument is a fish function then spawn another
    # fish shell in sudo to run it.
    # From: https://bsago.me/tech-notes/sudo-with-aliases-in-fish
    if functions -q -- $argv[1]
        set -l new_args (string join ' ' -- (string escape -- $argv))
        set argv fish -c "$new_args"
    end

    command sudo -E $argv
end
