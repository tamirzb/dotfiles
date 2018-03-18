function spotify
    if [ (xgetres Xft.dpi) -eq 192 ]
        set param "--force-device-scale-factor=2"
    end
    command spotify $param
end
