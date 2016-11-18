#!/bin/bash

WORKING_FOLDER=${BASH_SOURCE%/*}

say() {
    echo $1

    if [ "$AUDIO_HINTS" = true ] ; then
        espeak -s 150 "$1" --stdout | aplay -D "$SPEAKER"
    fi
}

expand_rootfs() {
    NUMBER_PATTERN=[0-9]+\.[0-9]+
    RESIZE_FS_MARKER=/mnt/boot/.resize-fs-needed
    DEVICE=/dev/mmcblk0

    # First let's check how much unallocated space we have, round float numbers
    # to a closest integer to use it later.
    FREE_MB=$(parted ${DEVICE} unit MB print free |\
              grep 'Free Space' |\
              tail -n1 |\
              awk '{print $3}' |\
              grep -o -E ${NUMBER_PATTERN} |\
              xargs printf '%.0f')

    # Get number of the root partition.
    ROOT_PART_NUM=$(parted ${DEVICE} -ms unit s p | tail -n 1 | cut -f 1 -d:)

    # If we have more than 100MB of unused space let's expand root partition to
    # use this space.
    if test "$FREE_MB" -gt 100
    then
        say "Please, wait until root partition is expanded."

        # Find out start offset of the root partition, to preserve it exactly
        # the same.
        ROOT_START_SECTOR=$(parted ${DEVICE} -ms unit s p |\
                            grep "^${ROOT_PART_NUM}" |\
                            cut -f 2 -d: |\
                            grep -o -E ${NUMBER_PATTERN})

        # Return value will be an error for fdisk as it fails to reload the
        # partition table because the root fs is mounted.
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

    git clone --depth ${SOURCE_GIT_HISTORY_DEPTH} -b ${SOURCE_GIT_BRANCH} ${SOURCE_GIT_LINK} ${SOURCE_LOCATION}

    if [ "$?" = "0" ]; then
        say "Source code has been successfully downloaded."
    else
        say "Source code can not be downloaded. Please make sure device is connected to the network."
        exit 1
    fi
}

check_source() {
    if [ ! -f ${SOURCE_LOCATION}/src/main.py ];
    then
        say "Lighthouse source code not found."
        exit 1
    fi
}

run_lighthouse() {
    gpio -g mode ${BUTTON_GPIO_PIN} up

    SERVICE_MODE=$(gpio -g read ${BUTTON_GPIO_PIN})

    # Run service mode script if user wants it. 0 means YES.
    if [ "$SERVICE_MODE" = 0 ] ; then
        say "Release the button."
        sleep 2
        /usr/bin/python ${SOURCE_LOCATION}/src/service_mode.py \
            --config-path ${WORKING_FOLDER}/boot.cfg \
            --audio-setup-path ${WORKING_FOLDER}/setup_audio.sh \
            --gpio-pin ${BUTTON_GPIO_PIN} &
    else
        say "Now starting Lighthouse."

        # Create the data/log directory if it does not exist
        # And run a web server there for monitoring
        mkdir -p ${DATA_LOCATION}
        (cd ${DATA_LOCATION}; python -m SimpleHTTPServer 80 &)

        # Run lighthouse and restart it any time it crashes
        while [ 1 ]; do
            /usr/bin/python ${SOURCE_LOCATION}/src/main.py \
                --verbose \
                --db-path ${DATA_LOCATION}/Data \
                --log-path ${DATA_LOCATION}/Log \
                --gpio-pin ${BUTTON_GPIO_PIN} \
                --audio-in-device ${MICROPHONE} \
                --audio-out-device ${SPEAKER} \
                --video-width ${VIDEO_WIDTH} \
                --video-height ${VIDEO_HEIGHT} \
                --motion-background-removal-strategy ${ACQUISITION_STRATEGY}
            sleep 1
            say "Lighthouse exited. Restarting."
        done &
    fi
}

# Import environment values.
. <(grep = ${WORKING_FOLDER}/boot.cfg)

# Setup audio.
. ${WORKING_FOLDER}/setup_audio.sh

expand_rootfs
checkout_source
check_source
run_lighthouse
