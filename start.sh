#!bin/sh
mountdisk(){
	if [ ! -f "ext4.img" ]; then
		dd if=/dev/zero of=ext4.img bs=512 count=131072
		mkfs.ext4 ext4.img
	fi
	if [ ! -d ./share ]; then
		mkdir ./share
	fi
	mount -t ext4 -o loop ext4.img ./share
	rm ./share/* -r
	cp -r ./test/* ./share
	#find ./share -type f | grep -v "mod.c" | grep -v "\.o" | grep -v "/\." | grep -v "\.symvers" | xargs -i cp --parents -r {} ./test
	umount ./share
}

createrootfs(){
	busybox_folder="busybox-1.34.0"
	rootfs="my-rootfs"

	echo $base_path
	if [ ! -d $rootfs ]; then
	        mkdir $rootfs
	fi
	cp $busybox_folder/_install/*  $rootfs/ -rf
	pushd $rootfs
	if [ ! -d proc ] && [ ! -d sys ] && [ ! -d dev ] && [ ! -d etc/init.d ]; then
	        mkdir proc sys dev etc etc/init.d
	fi

	if [ -f etc/init.d/rcS ]; then
	        rm etc/init.d/rcS
	fi
	echo '#!/bin/sh' > etc/init.d/rcS
	echo "mount -t proc none /proc" >> etc/init.d/rcS
	echo "mount -t sysfs none /sys" >> etc/init.d/rcS
	echo "/sbin/mdev -s" >> etc/init.d/rcS
	echo "mkdir /data"  >> etc/init.d/rcS
	echo "mount /dev/sda /data" >> etc/init.d/rcS
	echo "ifconfig eth0 192.168.5.61" >> etc/init.d/rcS
	echo "ifconfig lo 127.0.0.1" >> etc/init.d/rcS
	chmod +x etc/init.d/rcS
	if [ -f ../rootfs.img ]; then
		rm ../rootfs.img
	fi
	find . | cpio -o -Hnewc |gzip -9 > ../rootfs.img
	popd
	if [ -d $rootfs ]; then
		echo "delete rootfs"
		rm ./$rootfs -r
	fi
}

starttup(){
	tunctl -d tap0
	tunctl -t tap0 -u root
	ifconfig tap0 192.168.5.161 promisc up
}

qemustart(){
	flag=""
	if [ "$1" == "debug" ]; then
		flag=" -S -s"
	fi
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
}
mountdisk
qemustart $@