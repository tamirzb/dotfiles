function screenrecord -w wf-recorder
    wf-recorder -g (_select_region) -f /tmp/recording.mp4 $argv
end
