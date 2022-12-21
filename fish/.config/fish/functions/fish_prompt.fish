function fish_prompt --description 'Write out the prompt'
    set -l last_status $status

    # Git prompt config:

    # Show a bunch of information about a git repo
    # Note that for big repos where this ends up being slow, it can be disabled
    # with `git config --local bash.showInformativeStatus false`
    set -g __fish_git_prompt_show_informative_status 1
    # Show how many untracked files there are in the repository
    set -g __fish_git_prompt_showuntrackedfiles 1
    # Show how many stashes there are
    set -g __fish_git_prompt_showstashstate 1
    # Describe current HEAD relative to newer tag or branch, such as
    # `(master~4)`
    set -g __fish_git_prompt_describe_style branch
    # Allows distinguishing between detached and non-detached
    set -g __fish_git_prompt_showcolorhints 1

    # Git prompt colors
    set -g __fish_git_prompt_color_branch magenta --bold
    set -g __fish_git_prompt_color_branch_detached magenta
    set -g __fish_git_prompt_color_dirtystate blue
    set -g __fish_git_prompt_color_stagedstate yellow
    set -g __fish_git_prompt_color_invalidstate red
    set -g __fish_git_prompt_color_untrackedfiles 666
    set -g __fish_git_prompt_color_cleanstate green --bold
    set -g __fish_git_prompt_color_stashstate cyan

    set -l color_cwd
    set -l prefix
    set -l suffix
    switch "$USER"
        case root toor
            if set -q fish_color_cwd_root
                set color_cwd $fish_color_cwd_root
            else
                set color_cwd $fish_color_cwd
            end
            set suffix '#'
        case '*'
            set color_cwd $fish_color_cwd
            set suffix '$'
    end

    # Notify about background jobs
    set -l jobs_num (jobs -g | wc -l)
    if test $jobs_num -gt 0
        set_color $fish_color_jobs
        echo -n -s "[$jobs_num] "
        set_color normal
    end

    # Show user@host on SSH
    if set -q SSH_TTY
        echo -n -s "$USER" @
        set_color $fish_color_host
        echo -n -s (prompt_hostname)
        set_color normal
        echo -n -s ' '
    end

    # PWD
    set_color $color_cwd
    echo -n (prompt_pwd)
    set_color normal

    fish_git_prompt
    echo -n " "

    if not test $last_status -eq 0
        set_color $fish_color_error
    end

    echo -n "$suffix "

    set_color normal
end
