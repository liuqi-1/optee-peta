OUT_PATH = ./build/images
BCFG_PATH = ./build
PETA_IMAGE_PATH = ./petalinux/images/linux
ROOTFS_PATH = ./out-br/images

################################################################################
# Targets 
################################################################################
all: dpd bootimage fitimage
clean: dpd-clean bootimage-clean fitimage-clean

################################################################################
# Targets images
################################################################################
dpd:
	cd build && make optee-os	
	cd build && make tfa
	cd build && make bootgen
	cd build && make buildroot
dpd-clean:
	cd build && make optee-os-clean
	cd build && make tfa-clean
	cd build && make bootgen-clean
	cd build && make buildroot-clean

################################################################################
# Targets images
################################################################################
image-clean: bootimage-clean fitimage-clean
image: bootimage fitimage


################################################################################
# Targets bootimage
################################################################################
bootimage: dpd
	./bootgen/bootgen -arch zynqmp -image $(BCFG_PATH)/zynqmp.bif -w -o $(OUT_PATH)/BOOT.bin
bootimage-clean: 
	rm -f $(OUT_PATH)/BOOT.bin

################################################################################
# Targets fitimage
################################################################################
fitimage: 
	cp $(PETA_IMAGE_PATH)/image.ub $(OUT_PATH)/image.ub
	cp $(PETA_IMAGE_PATH)/boot.scr $(OUT_PATH)/boot.scr
	cp $(ROOTFS_PATH)/rootfs.tar $(OUT_PATH)/rootfs.tar
fitimage-clean: 
	rm -r $(OUT_PATH)/boot.scr
	rm -f $(OUT_PATH)/image.ub
	rm -r $(OUT_PATH)/rootfs.tar