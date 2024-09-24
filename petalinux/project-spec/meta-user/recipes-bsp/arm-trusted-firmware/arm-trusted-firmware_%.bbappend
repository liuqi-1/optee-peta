EXTRA_OEMAKE_append = " LOG_LEVEL=LOG_LEVEL_INFO"
EXTRA_OEMAKE_append = " NEED_BL32=yes"
EXTRA_OEMAKE_append = " SPD=opteed"
FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI += "file://0001-modify-the-atf-smc-handler-to-protect-the-pcap.patch"

