SUMMARY = "A picamera"
DESCRIPTION = "PICamera descriptio"
HOMEPAGE = "https://github.com/waveform80/picamera"
LICENSE = "BSD"
LIC_FILES_CHKSUM = "file://LICENSE.txt;md5=a5f6282f39d52726bdc1e51d5c4b95c9"

inherit pypi setuptools

SRC_URI[md5sum] = "97e1e8f0058c7ad079aa457e0a910b2b"
SRC_URI[sha256sum] = "c1d28e578385eac49bdb5f53bdb83c1075c400231593aa7fa246cdb04c67ad00"

PYPI_PACKAGE = "picamera"

RDEPENDS_${PN} = "${PYTHON_PN}-werkzeug ${PYTHON_PN}-jinja2 ${PYTHON_PN}-markupsafe"
