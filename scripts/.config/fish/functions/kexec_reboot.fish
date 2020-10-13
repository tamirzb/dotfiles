# At the moment, just running `systemctl kexec` isn't supported if you have
# multiple initrd entries, so this script is needed
function kexec_reboot
    sudo kexec -l /boot/vmlinuz-linux --initrd=/boot/initramfs-linux.img --reuse-cmdline
    sudo systemctl kexec
end
