function wireshark
    if [ (xgetres Xft.dpi) -eq 192 ]
        set -x QT_SCALE_FACTOR 2
    end
    command wireshark $argv
end
