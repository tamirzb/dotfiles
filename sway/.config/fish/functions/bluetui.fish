# If not running from a terminal, spawn it in a floating one
function bluetui --description 'Run bluetui in terminal or spawn Alacritty'
    if isatty stdin
        command bluetui $argv
    else
        alacritty --class "Alacritty-floating" -e bluetui $argv
    end
end
