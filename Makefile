PLATFORM		?= zcu102
PETAL_PATH		?= ./petalinux
OPTEE_VER		?= latest
XSA_FILE		?= axu3eg.xsa

PYTHON_PATH	?= ${PETAL_PATH}/project-spec/meta-user/recipes-devtools/python

define set_cfg
	@sed -i 's/$(1)=.*/$(1)=$(2)/' $(3)
endef

define set_optee_version
	@if [ "$(1)" != "latest" ]; then \
		echo 'OPTEE_VERSION ?= "$(1)"' > $(2); \
		echo 'SRCREV ?= "$(1)"' >> $(2); \
	else \
		echo 'OPTEE_VERSION ?= "latest"' > $(2); \
		echo 'SRCREV ?= "$${AUTOREV}"' >> $(2); \
	fi
endef

ifeq ($(PLATFORM),ultra96-reva)
	ZYNQMP_CONSOLE=cadence1
else
	ZYNQMP_CONSOLE=cadence0
endif

.PHONY: check
check:
ifndef PETALINUX_VER
	$(error You have to source Petalinux settings)
endif
ifneq ($(PETALINUX_VER),2020.2)
	$(error This makefile only support Petalinux 2020.2)
endif

################################################################
# create petalinux project
################################################################

# create: check
# 	@
# 	@# Create TMP directory to avoid issues with .. in the path name
# 	@mkdir -p /tmp/petalinux-optee-${PLATFORM}
# 	@petalinux-create -n $(PETAL_PATH) -t project --template zynqMP
# 	@cp build/zynqmp/xsa/$(XSA_FILE)  $(PETAL_PATH)/
# 	@cd ./petalinux && petalinux-config --get-hw-description=$(XSA_FILE)
# 	@#
# 	@# Append the ATF recipe to include opteed as SPD
# 	@mkdir -p ${PETAL_PATH}/project-spec/meta-user/recipes-bsp/arm-trusted-firmware
# 	@cp build/zynqmp/arm-trusted-firmware/*.bbappend ${PETAL_PATH}/project-spec/meta-user/recipes-bsp/arm-trusted-firmware/.
# 	@#
# 	@# Download optee package  recipes from meta-arm layer using gatesgarth branch as there were not available for zeus
# 	@cp -r build/zynqmp/meta-arm-3.2/meta-arm/recipes-security  ${PETAL_PATH}/project-spec/meta-user/
# 	@#
# 	@# Copy the bbapend files for our target
# 	@cp build/zynqmp/optee/* ${PETAL_PATH}/project-spec/meta-user/recipes-security/optee/
# 	@#
# 	@# Download python package dependencies from meta-core layer using gatesgarth branch as there were not available for zeus
# 	@mkdir -p ${PYTHON_PATH}
# 	@cp build/zynqmp/python/* ${PYTHON_PATH}/
# 	@#
# 	@# Add packages to the image
# 	@echo IMAGE_INSTALL_append = \" optee-os optee-client optee-test\" >> ${PETAL_PATH}/project-spec/meta-user/conf/petalinuxbsp.conf
# 	@#
# 	@# Add optee kernel options to the exisiting kernel append recipe
# 	@mkdir -p ${PETAL_PATH}/project-spec/meta-user/recipes-kernel/linux
# 	@echo FILESEXTRAPATHS_prepend := \"$$\{THISDIR\}/linux-xlnx:\" >> ${PETAL_PATH}/project-spec/meta-user/recipes-kernel/linux/linux-xlnx_%.bbappend
# 	@echo SRC_URI_append += \"file://kernel_optee.cfg\" >> ${PETAL_PATH}/project-spec/meta-user/recipes-kernel/linux/linux-xlnx_%.bbappend
# 	@mkdir -p ${PETAL_PATH}/project-spec/meta-user/recipes-kernel/linux/linux-xlnx
# 	@cp build/zynqmp/kernel/kernel_optee.cfg ${PETAL_PATH}/project-spec/meta-user/recipes-kernel/linux/linux-xlnx/kernel_optee.cfg
# 	@#
# 	@# Replace exisiting user configued dts file to add optee node
# 	@cp build/zynqmp/device-tree/system-user.dtsi ${PETAL_PATH}/project-spec/meta-user/recipes-bsp/device-tree/files/system-user.dtsi


###########################################################
# build the petalinux project
###########################################################

build: check
	@petalinux-build -p $(PETAL_PATH)

###########################################################
# make boot image
###########################################################

package: check
	@cd ./petalinux && petalinux-package --boot --pmufw --u-boot --add images/linux/tee_raw.bin --cpu a53-0 \
	    --file-attribute "load=0x60000000, startup=0x60000000, exception_level=el-1, trustzone" --force
	@mkdir -p ./build/images
	@cd ./build/images && rm -rf *
	@cp $(PETAL_PATH)/images/linux/image.ub ./build/images/
	@cp $(PETAL_PATH)/images/linux/boot.scr ./build/images/
	@cp $(PETAL_PATH)/images/linux/BOOT.BIN ./build/images/
	@cp $(PETAL_PATH)/images/linux/rootfs.tar.gz ./build/images/


###########################################################
# make and install the sysroot
###########################################################

sysroot:
	@cd petalinux && petalinux-build --sdk
	@cd petalinux && petalinux-package --sysroot
	
###########################################################
# clear the petalinux project
###########################################################

peta-clean:
	@petalinux-build -x distclean -p ${PETAL_PATH}
	# @petalinux-build -x mrproper -p ${PETAL_PATH} 


###############################################
# toolchains
###############################################
toolchains:
	@cd build && make -f toolchain.mk toolchains
	@export PATH=../toolchains/aarch64/bin:../toolchains/aarch32/bin:$PATH


##############################################
# optee-os
##############################################

optee-os: toolchains
	@ cd ./optee_os &&  make \
		CFG_ARM64_core=y \
		CFG_TEE_BENCHMARK=n \
		CFG_TEE_CORE_LOG_LEVEL=3 \
		CROSS_COMPILE=aarch64-linux-gnu- \
		CROSS_COMPILE_core=aarch64-linux-gnu- \
		CROSS_COMPILE_ta_arm32=arm-linux-gnueabihf- \
		CROSS_COMPILE_ta_arm64=aarch64-linux-gnu- \
		DEBUG=1 \
		O=out/arm \
		PLATFORM=vexpress-qemu_armv8a

optee-os-clean:
	@rm -rf ./optee_os/out

##############################################
# optee-client
##############################################

optee-client: toolchains
	@cd optee_client && make CROSS_COMPILE=aarch64-linux-gnu-

optee-client-clean:
	@rm -rf ./optee_client/out