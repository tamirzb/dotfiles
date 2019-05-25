# Remove a file from all snapper snapshots
function snapshots-rm -a subvol_path file_path
    set -l rm_params $argv[3..-1]

    echo "Removing $subvol_path/$file_path"
    rm $rm_params $subvol_path/$file_path

    for snapshot_num in (ls -1 $subvol_path/.snapshots)
        set -l snapshot $subvol_path/.snapshots/$snapshot_num/snapshot
        btrfs property set $snapshot ro false
        echo "Removing $snapshot/$file_path"
        rm $rm_params $snapshot/$file_path
        btrfs property set $snapshot ro true
    end
end
