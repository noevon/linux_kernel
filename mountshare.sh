#!bin/sh
if [ ! -f "ext4.img" ]; then
	dd if=/dev/zero of=ext4.img bs=512 count=131072
	mkfs.ext4 ext4.img
fi
mount -t ext4 -o loop ext4.img ./share


