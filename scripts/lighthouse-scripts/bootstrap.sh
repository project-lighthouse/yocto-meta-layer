#!/bin/sh

AUDIO_HINTS=true

SOURCE_GIT_BRANCH=prototype
SOURCE_LOCATION=/home/root/source

say() {
    echo $1

    if [ "$AUDIO_HINTS" = true ] ; then
        espeak -s 150 "$1"
    fi
}

prepare_audio() {
    /mnt/boot/scripts/cirrus-usecases/Record_from_DMIC.sh -q
    /mnt/boot/scripts/cirrus-usecases/Playback_to_Speakers.sh -q
}

expand_rootfs() {
    NUMBER_PATTERN=[0-9]+\.[0-9]+
    RESIZE_FS_MARKER=/mnt/boot/.resize-fs-needed
    DEVICE=/dev/mmcblk0

    # First let's check how much unallocated space we have, round float numbers to a closest integer to use it later.
    FREE_MB=$(parted ${DEVICE} unit MB print free |\
              grep 'Free Space' |\
              tail -n1 |\
              awk '{print $3}' |\
              grep -o -E ${NUMBER_PATTERN} |\
              xargs printf '%.0f')

    # Get number of the root partition.
    ROOT_PART_NUM=$(parted ${DEVICE} -ms unit s p | tail -n 1 | cut -f 1 -d:)

    # If we have more than 100MB of unused space let's expand root partition to use this space.
    if test "$FREE_MB" -gt 100
    then
        say "Please, wait until root partition is expanded."

        # Find out start offset of the root partition, to preserve it exactly the same.
        ROOT_START_SECTOR=$(parted ${DEVICE} -ms unit s p |\
                            grep "^${ROOT_PART_NUM}" |\
                            cut -f 2 -d: |\
                            grep -o -E ${NUMBER_PATTERN})

        # Return value will be an error for fdisk as it fails to reload the partition table because the root fs is mounted.
        printf "p\nd\n2\nn\np\n2\n$ROOT_START_SECTOR\n\np\nw\n" | fdisk -uc /dev/mmcblk0

        # Leave a marker to know that we need to call resize2fs afterwards.
        touch ${RESIZE_FS_MARKER}

        say "Rebooting device."
        shutdown -r now

        exit 0
    elif [ -f "$RESIZE_FS_MARKER" ]
    then
        say "Please, wait until partition information is updated. It can take some time."
        resize2fs -p "${DEVICE}p${ROOT_PART_NUM}"

        rm ${RESIZE_FS_MARKER}

        say "Rebooting device once again."
        shutdown -r now

        exit 0
    fi
}

checkout_source() {
    SOURCE_GIT_LINK=https://github.com/project-lighthouse/Lighthouse-2.git

    # Don't fetch source if source location already exists.
    if [ -d "$SOURCE_LOCATION" ]
    then
        return 0
    fi

    say "Please, wait until source code is downloaded."

    git clone -b ${SOURCE_GIT_BRANCH} ${SOURCE_GIT_LINK} ${SOURCE_LOCATION}

    if [ "$?" = "0" ]; then
        say "Source code has been successfully downloaded."
    else
        say "Source code can not be downloaded. Please make sure device is connected to the network."
        exit 1
    fi
}

run_lighthouse() {
    say "Lighthouse is ready!"
}

prepare_audio
expand_rootfs
checkout_source
run_lighthouse
