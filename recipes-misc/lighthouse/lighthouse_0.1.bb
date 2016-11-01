SUMMARY = "Lighthouse startup scripts"
SECTION = "console"

LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI += "file://init"

PR = "r0"

S = "${WORKDIR}"

inherit update-rc.d

INITSCRIPT_NAME = "lighthouse"
INITSCRIPT_PARAMS = "defaults"

do_install() {
	install -d ${D}${sysconfdir}/init.d
	install -m 0755 ${S}/init ${D}${sysconfdir}/init.d/lighthouse
}

FILES_${PN} += "${sysconfdir}"
