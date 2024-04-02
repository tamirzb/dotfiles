# Adds a binding to alt+tab which takes fish's completions (which you'd
# normally see pressing tab) but puts them in fzf. Basically a familiar fuzzy
# search for these completion options.

function _fzf_complete
    set -l selected_completions (
        # Get the completion options from the cursor position
        complete -C (commandline --cut-at-cursor) |\
        # Some completion options have descriptions. When that's the case, the
        # option and the description are separated by tab. To make it nicer,
        # color the description in blue and wrap it in braces
        string replace -r "(.+)\t(.+)" \
            '$1\t'(set_color blue)'($2)'(set_color normal) |\
        fzf \
            --multi \
            # Accept color in the input
            --ansi \
            # Only show descriptions but ignore them for searches
            --delimiter "\t" --nth 1
    )

    if test $status -eq 0
        for completion in $selected_completions
            # Remove the description after the choice
            set -f --append result (string split --no-empty --field=1 -- \
                                    (echo -e "\t") $completion)
        end

        # Put the selected completions in the command line
        commandline --current-token --replace -- (string join " " -- $result)
    end

    commandline --function repaint
end

bind \e\t _fzf_complete
