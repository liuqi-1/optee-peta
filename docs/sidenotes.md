# About PMU Firmware

**<u>*References*</u>**

- [PMU Firmware](https://xilinx-wiki.atlassian.net/wiki/spaces/A/pages/18841724/PMU+Firmware)

- [Build PMUFM](https://xilinx-wiki.atlassian.net/wiki/spaces/A/pages/18842462/Build+PMU+Firmware)

# About Evaluation Kit

- 开发套件，包含硬件、配套软件和文档
- zc702和zc706都是xilinx官方推出的开发板（$开发板 \neq 芯片$）
- zc702搭载 xc7z020 芯片，zc706 搭载 xc7z045 芯片

# Fit image

- `image & vmlinux`: 内核经过编译后，会生成一个`elf`的可执行程序，called `vmlinux`，这是未经过任何加工的原始内核`elf`文件。不过最终烧写在嵌入式设备上的并不是这个文件，而是经过工具加工之后的专门用于烧录的镜像格式 image
- `zImage`: 对 image 进行压缩，并在压缩文件前附加解压缩代码，构成了一个压缩格式的镜像文件就叫做 `zImage`
- `uImage`: Uboot想要正确启动Linux内核，就需要知道内核的信息，比如镜像的类型，镜像在内存的位置，镜像文件是否压缩等。Uboot为拿到这些信息，发明了一种内核格式叫uImage，也叫做Legacy uImage。uImage是由zImage加工得到，uboot中有一个工具mkimage，该工具会给zImage加一个64字节的header，将启动内核所需要的信息存储在header中。uboot启动后，从header中读取所需要的信息
- `FIT Image`: ARM社区引入了Device Tree，使用Device Tree后，许多硬件的细节可以直接传递给Linux，而不需要在kernel中进行大量冗余编码。Uboot为支持这种特性，在uImage中加入多个dtb文件和ramdisk文件，成为 `FIT Image`
- [Ref. Secure Boot fit image](https://www.cnblogs.com/dongxb/p/16717565.html)

# About bif file

- Bootgen defines a boot image format(BIF) to contain multiple properties and attributes  for genegrating the boot images.  Along with properties and attributes, Bootgen takes multiple commands to define the behavior while it is creating the boot images.
- A BIF comprises of the following:
  - Configuration attributes to create secure/non-secure boot images
  - Bootloader
    - FSBL for Zynq and Zynq UltraScale+ MPSoC
    - Platform loader and manager for AMD Versal adaptive SoC
  - One or more partition images
- The  boot header is required by the BoorROM loader which loads a single partition, typically the bootloader. The remainder of the boot image is loaded and processed by the bootloader.
- The BIF file specifies each component of the boot image, in order of boot, and follows optional attributes to be applied to each image component.

























