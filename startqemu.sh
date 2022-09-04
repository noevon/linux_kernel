#!/bin/bash
flag=""
if [ "$1" == "debug"  ]; then
    flag=" -S -s"
fi
source createtap.sh
umount ./share
qemu-system-x86_64 \
         -m size=1024M \
         -kernel ./linux-4.14/arch/x86_64/boot/bzImage \
         -initrd ./rootfs.img \
         -append "console=ttyS0 rdinit=/linuxrc nokaslr" \
         -nographic \
	 -smp 1 \
	 -net nic -net tap,ifname=tap0,script=no,downscript=no \
	 -hdb ./ext4.img \
         $flag
