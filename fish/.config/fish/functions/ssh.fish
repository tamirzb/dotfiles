# Wrapper to change background color to strongly differentiate between SSH and
# local terminals
# Executes a seperate file because it needs to trap SIGINT and for some reason
# that works in executed files but not in functions (ref:
# https://github.com/fish-shell/fish-shell/issues/6649#issuecomment-1198951287)

function ssh
    set -l function_dir (path dirname (status filename))
    set -l fish_dir (path dirname $function_dir)

    fish $fish_dir/lib/ssh-bg-exec.fish $argv
end
