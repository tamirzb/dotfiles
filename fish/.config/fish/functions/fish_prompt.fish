function fish_prompt --description 'Write out the prompt'
    set -l last_status $status

    if not set -q __fish_git_prompt_show_informative_status
        set -g __fish_git_prompt_show_informative_status 1
    end
    if not set -q __fish_git_prompt_hide_untrackedfiles
        set -g __fish_git_prompt_hide_untrackedfiles 1
    end
    if not set -q __fish_git_prompt_showstashstate
        set -g __fish_git_prompt_showstashstate 1
    end
    if not set -q __fish_git_prompt_showcolorhints
        set -g __fish_git_prompt_showcolorhints 1
    end
    if not set -q __fish_git_prompt_describe_style
        set -g __fish_git_prompt_describe_style branch
    end

    if not set -q __fish_git_prompt_color_branch
        set -g __fish_git_prompt_color_branch magenta --bold
    end
    if not set -q __fish_git_prompt_color_branch_detached
        set -g __fish_git_prompt_color_branch_detached magenta
    end
    if not set -q __fish_git_prompt_color_dirtystate
        set -g __fish_git_prompt_color_dirtystate blue
    end
    if not set -q __fish_git_prompt_color_stagedstate
        set -g __fish_git_prompt_color_stagedstate yellow
    end
    if not set -q __fish_git_prompt_color_invalidstate
        set -g __fish_git_prompt_color_invalidstate red
    end
    if not set -q __fish_git_prompt_color_untrackedfiles
        set -g __fish_git_prompt_color_untrackedfiles $fish_color_normal
    end
    if not set -q __fish_git_prompt_color_cleanstate
        set -g __fish_git_prompt_color_cleanstate green --bold
    end
    if not set -q __fish_git_prompt_color_stashstate
        set -g __fish_git_prompt_color_stashstate cyan
    end

    if not set -q __fish_prompt_normal
        set -g __fish_prompt_normal (set_color normal)
    end

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
