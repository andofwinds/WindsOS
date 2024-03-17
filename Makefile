ASM=nasm
CC=gcc

SRC_DIR=src
TOOLS_DIR=tools
BUILD_DIR=build

.PHONY: all floppy_image kernel bootloader watersh microsh binutils clean always tools_fat

all: floppy_image tools_fat

#
# Floppy image
#
floppy_image: $(BUILD_DIR)/main_floppy.img

$(BUILD_DIR)/main_floppy.img: bootloader kernel binutils
	dd if=/dev/zero of=$(BUILD_DIR)/main_floppy.img bs=512 count=2880
	mkfs.fat -F 12 -n "FWOS" $(BUILD_DIR)/main_floppy.img
	dd if=$(BUILD_DIR)/bootloader.bin of=$(BUILD_DIR)/main_floppy.img conv=notrunc
	mcopy -i $(BUILD_DIR)/main_floppy.img $(BUILD_DIR)/kernel.bin "::kernel.bin"
#	mcopy -i $(BUILD_DIR)/main_floppy.img $(BUILD_DIR)/watersh.bin "::watersh.bin"
#	mcopy -i $(BUILD_DIR)/main_floppy.img $(BUILD_DIR)/microsh.bin "::microsh.bin"
	mcopy -i $(BUILD_DIR)/main_floppy.img $(BUILD_DIR)/securemd.bin "::securemd.bin"
	mcopy -i $(BUILD_DIR)/main_floppy.img $(BUILD_DIR)/reboot.bin "::reboot.bin"
#	mcopy -i $(BUILD_DIR)/main_floppy.img $(BUILD_DIR)/graphx.bin "::graphx.bin"
	mcopy -i $(BUILD_DIR)/main_floppy.img test.txt "::test.txt"

#
# Bootloader
#
bootloader: $(BUILD_DIR)/bootloader.bin

$(BUILD_DIR)/bootloader.bin: always
	$(ASM) $(SRC_DIR)/boot/stage1/ultraboot.asm -f bin -o $(BUILD_DIR)/bootloader.bin

#
# Kernel
#
kernel: $(BUILD_DIR)/kernel.bin

$(BUILD_DIR)/kernel.bin: always
	$(ASM) $(SRC_DIR)/kernel/main.asm -f bin -o $(BUILD_DIR)/kernel.bin
#	make -C $(SRC_DIR)/kernel BUILD_DIR=$(abspath $(BUILD_DIR))


#
# SHELLS 
#
watersh: $(BUILD_DIR)/watersh.bin
$(BUILD_DIR)/watersh.bin: always
	$(ASM) $(SRC_DIR)/kernel/watersh.asm -f bin -o $(BUILD_DIR)/watersh.bin

microsh: $(BUILD_DIR)/microsh.bin
$(BUILD_DIR)/microsh.bin: always
	$(ASM) $(SRC_DIR)/kernel/microsh.asm -f bin -o $(BUILD_DIR)/microsh.bin


#
# BINUTILS
#
binutils: securemd reboot graphx

reboot: $(BUILD_DIR)/reboot.bin
$(BUILD_DIR)/reboot.bin: always
	$(ASM) $(SRC_DIR)/bin/reboot.asm -f bin -o $(BUILD_DIR)/reboot.bin


securemd: $(BUILD_DIR)/securemd.bin
$(BUILD_DIR)/securemd.bin: always
	$(ASM) $(SRC_DIR)/bin/securemd.asm -f bin -o $(BUILD_DIR)/securemd.bin

graphx: $(BUILD_DIR)/graphx.bin
$(BUILD_DIR)/graphx.bin: always
	$(ASM) $(SRC_DIR)/bin/graphx.asm -f bin -o $(BUILD_DIR)/graphx.bin

#
# Tools
#
tools_fat: $(BUILD_DIR)/tools/fat
$(BUILD_DIR)/tools/fat: always $(TOOLS_DIR)/fat/fat.c
	mkdir -p $(BUILD_DIR)/tools
	$(CC) -g -o $(BUILD_DIR)/tools/fat $(TOOLS_DIR)/fat/fat.c

#
# Always
#
always:
	mkdir -p $(BUILD_DIR)

#
# Clean
#
clean:
	rm -rf $(BUILD_DIR)/*