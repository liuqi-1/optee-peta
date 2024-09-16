################################################################################
# Following variables defines how the NS_USER (Non Secure User - Client
# Application), NS_KERNEL (Non Secure Kernel), S_KERNEL (Secure Kernel) and
# S_USER (Secure User - TA) are compiled
################################################################################
override COMPILE_NS_USER   := 64
override COMPILE_NS_KERNEL := 64
override COMPILE_S_USER    := 64
override COMPILE_S_KERNEL  := 64

PLATFORM := zynqmp-zcu102
OPTEE_OS_PLATFORM = $(PLATFORM)

DTS_zynqmp-zcu102 = zynqmp-zcu102-rev1.0
DTS_zynqmp-zcu104 = zynqmp-zcu104-revC
DTS_zynqmp-zcu106 = zynqmp-zcu106-revA
DTS_zynqmp-ultra96 = avnet-ultra96-rev1
U-BOOT_DTS = $(DTS_$(PLATFORM))

################################################################################
# Paths to git projects and various binaries
################################################################################
TF_A_PATH		?= $(ROOT)/arm-trusted-firmware
U-BOOT_PATH		?= $(ROOT)/u-boot-xlnx
BOOTGEN_PATH		?= $(ROOT)/bootgen
LINUX_PATH		?= $(ROOT)/linux-xlnx

include common.mk

################################################################################
# Targets
################################################################################
include toolchain.mk

################################################################################
# ARM Trusted Firmware
################################################################################
TF_A_EXPORTS = CROSS_COMPILE="$(CCACHE)$(AARCH64_CROSS_COMPILE)"
TF_A_FLAGS  = PLAT=zynqmp RESET_TO_BL31=1 NEED_BL32=yes SPD=opteed LOG_LEVEL=LOG_LEVEL_INFO


tfa:
	$(TF_A_EXPORTS) $(MAKE) -C $(TF_A_PATH) $(TF_A_FLAGS) bl31

tfa-clean:
	$(TF_A_EXPORTS) $(MAKE) -C $(TF_A_PATH) $(TF_A_FLAGS) clean

################################################################################
# OP-TEE
#################################################################################
optee-os: optee-os-common
	${OPTEE_OS_PATH}/scripts/gen_tee_bin.py --input ${OPTEE_OS_PATH}/out/arm/core/tee.elf --out_tee_raw_bin ${OPTEE_OS_PATH}/out/arm/core/tee_raw.bin

optee-os-clean: optee-os-clean-common
	rm -f ${OPTEE_OS_PATH}/out/arm/core/tee_raw.bin


###############################################################################
# Bouildroot
###############################################################################
BR2_TARGET_GENERIC_ISSUE="OP-TEE embedded distrib for $(PLATFORM)"
BR2_TARGET_ROOTFS_EXT2=y
BR2_PACKAGE_BUSYBOX_WATCHDOG=y
BR2_TARGET_GENERIC_GETTY_PORT=ttyPS0

# TF-A, Linux kernel, U-Boot and OP-TEE OS/Client/... are not built from their
# related Buildroot native package.
BR2_TARGET_ARM_TRUSTED_FIRMWARE=n
BR2_LINUX_KERNEL=n
BR2_TARGET_OPTEE_OS=n
BR2_TARGET_UBOOT=n
BR2_PACKAGE_OPTEE_CLIENT=n
BR2_PACKAGE_OPTEE_TEST=n
BR2_PACKAGE_OPTEE_EXAMPLES=n
BR2_PACKAGE_OPTEE_BENCHMARK=n


###############################################################################
# Bootgen
###############################################################################
bootgen:
	make -C $(BOOTGEN_PATH)

bootgen-clean:
	make -C $(BOOTGEN_PATH) clean