##############################################
# all target
##############################################
all: optee-os optee-client toolchain-path
clean: optee-os-clean optee-client-clean


###############################################
# toolchains
###############################################
toolchain-path:
	@cd .. && make toolchains
	@export PATH=../toolchains/aarch64/bin:../toolchains/aarch32/bin:$PATH


##############################################
# optee-os
##############################################

optee-os: toolchain-path
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

optee-client: toolchain-path
	@mkdir -p ./optee_client/out
	@cd ./optee_client/out && cmake -DCMAKE_C_COMPILER=aarch64-linux-gnu-gcc ..
	@cd ./optee_client/out && make

optee-client-clean:
	@rm -rf ./optee_client/out