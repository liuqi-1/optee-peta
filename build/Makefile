PLATFORM		?= zcu102
PETAL_PATH		?= ../petalinux
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

create: check
	@
	@# Create TMP directory to avoid issues with .. in the path name
	@mkdir -p /tmp/petalinux-optee-${PLATFORM}
	@petalinux-create -n $(PETAL_PATH) -t project --template zynqMP --tmpdir /tmp/petalinux-optee-${PLATFORM}
	@cp zynqmp/xsa/$(XSA_FILE)  $(PETAL_PATH)/
	@cd ../petalinux && petalinux-config --get-hw-description=$(XSA_FILE)
	@#
	@# Append the ATF recipe to include opteed as SPD
	@mkdir -p ${PETAL_PATH}/project-spec/meta-user/recipes-bsp/arm-trusted-firmware
	@cp zynqmp/arm-trusted-firmware/*.bbappend ${PETAL_PATH}/project-spec/meta-user/recipes-bsp/arm-trusted-firmware/.
	@#
	@# Download optee package  recipes from meta-arm layer using gatesgarth branch as there were not available for zeus
	@cp -r zynqmp/meta-arm-3.2/meta-arm/recipes-security  ${PETAL_PATH}/project-spec/meta-user/
	@#
	@# Copy the bbapend files for our target
	@cp zynqmp/optee/* ${PETAL_PATH}/project-spec/meta-user/recipes-security/optee/
	@#
	@# Download python package dependencies from meta-core layer using gatesgarth branch as there were not available for zeus
	@mkdir -p ${PYTHON_PATH}
	@curl -s http://cgit.openembedded.org/openembedded-core/plain/meta/recipes-devtools/python/python3-pycryptodome_3.9.8.bb?h=gatesgarth \
	-o ${PYTHON_PATH}/python3-pycryptodome_3.9.8.bb
	@curl -s http://cgit.openembedded.org/openembedded-core/plain/meta/recipes-devtools/python/python3-pycryptodomex_3.9.8.bb?h=gatesgarth \
	 -o ${PYTHON_PATH}/python3-pycryptodomex_3.9.8.bb
	@curl -s http://cgit.openembedded.org/openembedded-core/plain/meta/recipes-devtools/python/python3-pyelftools_0.26.bb?h=gatesgarth  \
	-o ${PYTHON_PATH}/python3-pyelftools_0.26.bb
	@curl -s http://cgit.openembedded.org/openembedded-core/plain/meta/recipes-devtools/python/python-pycryptodome.inc?h=gatesgarth \
	-o ${PYTHON_PATH}/python-pycryptodome.inc
	@#
	@# Add packages to the image
	@echo IMAGE_INSTALL_append = \" optee-os optee-client optee-test\" >> ${PETAL_PATH}/project-spec/meta-user/conf/petalinuxbsp.conf
	@#
	@# Add optee kernel options to the exisiting kernel append recipe
	@mkdir -p ${PETAL_PATH}/project-spec/meta-user/recipes-kernel/linux
	@echo SRC_URI_append += \"file://kernel_optee.cfg\" >> ${PETAL_PATH}/project-spec/meta-user/recipes-kernel/linux/linux-xlnx_%.bbappend
	@mkdir -p ${PETAL_PATH}/project-spec/meta-user/recipes-kernel/linux/linux-xlnx
	@cp zynqmp/kernel/kernel_optee.cfg ${PETAL_PATH}/project-spec/meta-user/recipes-kernel/linux/linux-xlnx/kernel_optee.cfg
	@#
	@# Replace exisiting user configued dts file to add optee node
	@cp zynqmp/device-tree/system-user.dtsi ${PETAL_PATH}/project-spec/meta-user/recipes-bsp/device-tree/files/system-user.dtsi

build: 
	@petalinux-build -p $(PETAL_PATH)
	
package: check build
	@petalinux-package --boot --pmufw --fpga --u-boot --add ${PETAL_PATH}/images/linux/tee_raw.bin --cpu a53-0 \
	    --file-attribute "load=0x60000000, startup=0x60000000, exception_level=el-1, trustzone" --force -p ${PETAL_PATH}
	@cp $(PETAL_PATH)/images/linux/image.ub ./images/
	@cp $(PETAL_PATH)/images/linux/boot.scr ./images/
	@cp $(PETAL_PATH)/images/linux/BOOT.BIN ./images/
	@cp $(PETAL_PATH)/images/linux/rootfs.tar.gz ./images/