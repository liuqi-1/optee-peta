export V ?= 0

OUTPUT_DIR := $(CURDIR)/out
ROOT = $(shell pwd)/../

EXAMPLE_LIST := $(subst /,,$(dir $(wildcard */Makefile)))

HOST_CROSS_COMPILE = aarch64-linux-gnu-

.PHONY: all
all: examples prepare-for-rootfs

.PHONY: clean
clean: examples-clean prepare-for-rootfs-clean

examples:
	@for example in $(EXAMPLE_LIST); do \
		$(MAKE) -C $$example CROSS_COMPILE="$(HOST_CROSS_COMPILE)" \
			TEEC_EXPORT="$(ROOT)/optee_client/out/export/usr" \
			TA_DEV_KIT_DIR="$(ROOT)/optee_os/out/arm/export-ta_arm64" \
			|| exit -1; \
	done

examples-clean:
	@for example in $(EXAMPLE_LIST); do \
		$(MAKE) -C $$example clean \
			TA_DEV_KIT_DIR="$(ROOT)/optee_os/out/arm/export-ta_arm64" \
			|| exit -1; \
	done

prepare-for-rootfs: examples
	@echo "Copying example CA and TA binaries to $(OUTPUT_DIR)..."
	@mkdir -p $(OUTPUT_DIR)
	@mkdir -p $(OUTPUT_DIR)/ta
	@mkdir -p $(OUTPUT_DIR)/ca
	@for example in $(EXAMPLE_LIST); do \
		if [ -e $$example/host/user-ta-$$example ]; then \
			cp -p $$example/host/user-ta-$$example $(OUTPUT_DIR)/ca/; \
		fi; \
		cp -pr $$example/ta/*.ta $(OUTPUT_DIR)/ta/; \
	done

prepare-for-rootfs-clean:
	@rm -rf $(OUTPUT_DIR)/ta
	@rm -rf $(OUTPUT_DIR)/ca
	@rmdir --ignore-fail-on-non-empty $(OUTPUT_DIR) || test ! -e $(OUTPUT_DIR)