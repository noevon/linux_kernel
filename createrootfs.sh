#!/bin/sh
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
