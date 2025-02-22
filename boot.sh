qemu-system-x86_64 \
-net nic \
-net user,hostfwd=tcp::10022-:22 \
-m 6024M \
-smp 8 \
-vnc none \
-drive "file=$1,index=0,format=qcow2,media=disk" \
-drive file=init.iso,index=1,media=cdrom \
-nographic
