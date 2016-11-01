#!/bin/bash

if [ -n "$1" ]; then
	IMAGE_FILE=$1
else
	echo -e "\nUsage: sudo $0 <image file>\n"
	echo -e "Example: sudo $0 rpi-image.img\n"
	exit 1
fi

if [ -n "$2" ]; then
	SIZE=$2
else
	SIZE=1048576
fi

echo -e "\nWorking on $IMAGE (size is ${SIZE})\n"

dd if=/dev/zero of=$IMAGE_FILE bs=1024 count=$SIZE

DEVICE=$(losetup -f)

sudo losetup $DEVICE $IMAGE_FILE

echo "Message ${DEVICE:5:5}"

sudo ./mk2parts.sh ${DEVICE:5:5}

sudo partprobe $DEVICE

sudo MACHINE=raspberrypi2 OETMP=/projects/mozilla/project-lighthouse/yocto/poky-tmp ./copy_boot.sh ${DEVICE:5:5}

sudo MACHINE=raspberrypi2 OETMP=/projects/mozilla/project-lighthouse/yocto/poky-tmp ./copy_rootfs.sh ${DEVICE:5:5}

sudo losetup -d $DEVICE

echo -e "\nImage is ready!\n"

