SUMMARY = "A console Lighthouse image"
HOMEPAGE = "https://github.com/project-lighthouse/yocto-meta-layer"
LICENSE = "MIT"

IMAGE_LINGUAS = "en-us"

inherit core-image

DEPENDS += "bcm2835-bootfiles"

CORE_OS = " \
    openssh openssh-keygen openssh-sftp-server \
    term-prompt \
    tzdata \
"

WIFI_SUPPORT = " \
    crda \
    dhcpcd \
    iw \
    linux-firmware-brcm43430 \
    linux-firmware-ralink \
    linux-firmware-rtl8192ce \
    linux-firmware-rtl8192cu \
    linux-firmware-rtl8192su \
    wireless-tools \
    wpa-supplicant \
"

DEV_SDK_INSTALL = " \
    coreutils \
    diffutils \
    file \
    gettext \
    git \
    ldd \
    perl-modules \
    python-pyalsaaudio \
    python-modules \
    python3-modules \
    python3-pydoc \
"

EXTRA_TOOLS_INSTALL = " \
    dosfstools \
    e2fsprogs \
    e2fsprogs-resize2fs \
    ethtool \
    findutils \
    iperf \
    iproute2 \
    less \
    netcat \
    parted \
    procps \
    rsync \
    sysfsutils \
    tcpdump \
    unzip \
    util-linux \
    wget \
    zip \
"

RPI_STUFF = " \
    bcm2835-tests \
    rpio \
    rpi-gpio \
    userland \
    wiringpi \
"

ALSA += " \
    alsa-dev \
    alsa-lib \
    alsa-utils \
    alsa-utils-scripts \
"

LIGHTHOUSE = " \
   espeak \
   vim \
   lrzsz \
   opencv \
   lighthouse \
   samba \
   avahi-daemon \
"

IMAGE_INSTALL += " \
    ${CORE_OS} \
    ${DEV_SDK_INSTALL} \
    ${EXTRA_TOOLS_INSTALL} \
    ${RPI_STUFF} \
    ${WIFI_SUPPORT} \
    ${ALSA} \
    ${LIGHTHOUSE} \
"

set_local_timezone() {
    ln -sf /usr/share/zoneinfo/EST5EDT ${IMAGE_ROOTFS}/etc/localtime
}

disable_bootlogd() {
    echo BOOTLOGD_ENABLE=no > ${IMAGE_ROOTFS}/etc/default/bootlogd
}

ROOTFS_POSTPROCESS_COMMAND += " \
    set_local_timezone ; \
    disable_bootlogd ; \
"

export IMAGE_BASENAME = "console-image"

