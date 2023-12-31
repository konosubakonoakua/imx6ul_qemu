TOOL_CHAIN = arm-none-eabi-
CC = ${TOOL_CHAIN}gcc
AS = ${TOOL_CHAIN}as
LD = ${TOOL_CHAIN}ld
OBJCOPY = ${TOOL_CHAIN}objcopy
OBJDUMP = $(TOOL_CHAIN)objdump

CFLAGS 		:= -Wall -g -fno-builtin -gdwarf-2 -gstrict-dwarf -Iinclude -mcpu=cortex-a7
LDFLAGS 	:= -g

objs := start.o \
		entry.o \
		driver/imx_uart.o \
		driver/imx_gpio.o \
		driver/imx_usdhc.o \
		driver/imx_i2c.o \
		device/at24cxx.o \
		device/qemu_print.o \
		device/timer.o \
		device/sd_card.o \
		fatfs/diskio.o \
		fatfs/ff.o \
		fatfs/ffsystem.o \
		fatfs/ffunicode.o

6ul_bare_metal.bin: $(objs)
	${LD} -T 6ul_bare_metal.ld -o 6ul_bare_metal.elf $(filter-out qemu_install, $^)
	${OBJCOPY} -O binary -S 6ul_bare_metal.elf $@
	${OBJDUMP} -D -m arm 6ul_bare_metal.elf > 6ul_bare_metal.dis

SHELL := /bin/bash
clangd: clean
	$(shell \
	set -e;\
	deps=(bear);\
	dpkg -s $${deps[*]} >/dev/null;\
	[[ ! $$? -eq 0 ]] && sudo apt install $${deps[*]};\
	)
	bear --output compile_commands.json -- make -j

qemu_install:
	@set -e
	@bash -c "./qemu_install.sh"

run: $(objs) qemu_install
	${LD} -T 6ul_bare_metal.ld -o 6ul_bare_metal.elf $(filter-out qemu_install, $^)
	${OBJCOPY} -O binary -S 6ul_bare_metal.elf 6ul_bare_metal.bin
	${OBJDUMP} -D -m arm 6ul_bare_metal.elf > 6ul_bare_metal.dis
	./qemu/bin/qemu-system-arm -M mcimx6ul-evk -show-cursor -m 512M -kernel 6ul_bare_metal.elf \
 	-display sdl -serial mon:stdio \
 	-nic user -com 100ask -sd test.img

nogui: $(objs) qemu_install
	${LD} -T 6ul_bare_metal.ld -o 6ul_bare_metal.elf $(filter-out qemu_install, $^)
	${OBJCOPY} -O binary -S 6ul_bare_metal.elf 6ul_bare_metal.bin
	${OBJDUMP} -D -m arm 6ul_bare_metal.elf > 6ul_bare_metal.dis
	./qemu/bin/qemu-system-arm -M mcimx6ul-evk -m 512M -kernel 6ul_bare_metal.elf -serial mon:stdio -nographic -sd test.img

fatfs: $(objs) qemu_install
	${LD} -T 6ul_bare_metal.ld -o 6ul_bare_metal.elf $(filter-out qemu_install, $^)
	${OBJCOPY} -O binary -S 6ul_bare_metal.elf 6ul_bare_metal.bin
	${OBJDUMP} -D -m arm 6ul_bare_metal.elf > 6ul_bare_metal.dis
	./qemu/bin/qemu-system-arm -M mcimx6ul-evk -m 512M -kernel 6ul_bare_metal.elf -serial mon:stdio -nographic -sd testfs.img

debug: $(objs) qemu_install
	${LD} -T 6ul_bare_metal.ld -o 6ul_bare_metal.elf $(filter-out qemu_install, $^)
	${OBJCOPY} -O binary -S 6ul_bare_metal.elf 6ul_bare_metal.bin
	${OBJDUMP} -D -m arm 6ul_bare_metal.elf > 6ul_bare_metal.dis
	./qemu/bin/qemu-system-arm -M mcimx6ul-evk  -show-cursor -m 512M -kernel 6ul_bare_metal.elf \
 	-display sdl -serial mon:stdio \
 	-nic user -com 100ask -device sd-card -S -s

%.o:%.c
	${CC} $(CFLAGS) -c -o $@ $<

%.o:%.s
	${CC} $(CFLAGS) -c -o $@ $<

clean:
	rm -rf *.o *.elf *.bin *.dis driver/*.o device/*.o fatfs/*.o


.PHONY: qemu_install run clean debug fatfs nogui clangd
