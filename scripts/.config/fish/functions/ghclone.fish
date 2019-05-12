function ghclone --description 'ghclone author/repo' -w 'git clone'
    git clone $argv[2..-1] git@github.com:$argv[1].git
end
