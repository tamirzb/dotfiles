function pavucontrol
    if [ (xgetres Xft.dpi) -eq 192 ]
        set -x GDK_DPI_SCALE 0.5
        set -x GDK_SCALE 2
    end
    command pavucontrol $argv
end
