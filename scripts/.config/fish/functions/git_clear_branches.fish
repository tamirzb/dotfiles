function git_clear_branches
    echo "Fetching..."
    git fetch -p
    set -l gone_branches 
    for branch in (git for-each-ref --format '%(refname) %(upstream:track)' refs/heads |\
                   awk '$2 == "[gone]" {sub("refs/heads/", "", $1); print $1}')
        read -l -P "Delete branch \"$branch\"? [Y/n] " confirm
        if contains $confirm '' Y y
            git branch -D $branch
        end
    end
end
