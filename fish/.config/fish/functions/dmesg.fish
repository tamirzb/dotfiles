function dmesg -w dmesg
    if test (count $argv) -eq 0
        command dmesg -H
    else
        command dmesg $argv
    end
end
