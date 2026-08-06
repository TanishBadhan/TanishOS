ASM = nasm
CC = gcc
LD = ld

CFLAGS = -m32 -ffreestanding -nostdlib -fno-pic -fno-stack-protector
LDFLAGS = -m elf_i386 -T linker.ld

all: build/tanishos.img

build:
	mkdir -p build

build/entry.o: kernel/entry.asm | build
	$(ASM) -f elf32 kernel/entry.asm -o build/entry.o

build/kernel.o: kernel/kernel.c | build
	$(CC) $(CFLAGS) -c kernel/kernel.c -o build/kernel.o

build/kernel.elf: build/entry.o build/kernel.o
	$(LD) $(LDFLAGS) -o build/kernel.elf build/entry.o build/kernel.o

build/kernel.bin: build/kernel.elf
	objcopy -O binary build/kernel.elf build/kernel.bin

boot/stage1.bin: boot/stage1.asm
	$(ASM) -f bin boot/stage1.asm -o boot/stage1.bin

boot/stage2.bin: boot/stage2.asm
	$(ASM) -f bin boot/stage2.asm -o boot/stage2.bin

build/tanishos.img: boot/stage1.bin boot/stage2.bin build/kernel.bin
	dd if=/dev/zero of=build/tanishos.img bs=512 count=2880
	dd if=boot/stage1.bin of=build/tanishos.img conv=notrunc
	dd if=boot/stage2.bin of=build/tanishos.img bs=512 seek=1 conv=notrunc
	dd if=build/kernel.bin of=build/tanishos.img bs=512 seek=2 conv=notrunc

run: build/tanishos.img
	qemu-system-i386 -drive if=floppy,format=raw,file=build/tanishos.img

clean:
	rm -rf build/*.o build/*.elf build/*.bin build/*.img
	rm -f boot/*.bin