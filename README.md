# TanishOS

A 32-bit x86 operating system built from scratch using Assembly and C to understand how computers boot, transition into protected mode, and execute a custom kernel.

---

## Overview

TanishOS is an educational operating system project focused on understanding low-level computer architecture and system software by building each component from scratch.

Instead of relying on existing operating system frameworks, this project implements the complete boot sequence — from BIOS bootloader execution to a custom C kernel — to gain practical experience with x86 architecture, memory handling fundamentals, hardware interaction, and kernel development.

The project is developed as a hands-on systems engineering exercise with emphasis on debugging, architecture, and understanding how software communicates directly with hardware.

---

# Architecture

The current boot flow of TanishOS is:

```text
                 BIOS
                  │
                  ▼
      Stage 1 Bootloader (512 Bytes)
                  │
                  ▼
         Stage 2 Bootloader
                  │
      Enable A20 Line
                  │
      Load Global Descriptor Table
                  │
      Switch to Protected Mode
                  │
                  ▼
        Load Kernel from Disk
                  │
                  ▼
      _start (Assembly Entry Point)
                  │
                  ▼
        kernel_main() (C Kernel)
                  │
                  ▼
          VGA Text Output
```

---

# Current Features

- Custom BIOS bootloader
- Two-stage bootloading process
- A20 line enabling
- Global Descriptor Table (GDT)
- 32-bit Protected Mode transition
- Custom linker script
- Assembly to C kernel handoff
- VGA text mode output
- Build system using NASM, GCC and LD
- Debugging using QEMU and GDB

---

# Debugging Journey

Developing TanishOS involved iterative low-level debugging to understand and verify each stage of the boot process.

Some of the debugging tasks included:

- Verifying BIOS successfully loaded Stage 1.
- Confirming Stage 2 was loaded into memory.
- Inspecting memory using `xxd`.
- Validating the Global Descriptor Table (GDT).
- Investigating protected mode transition failures.
- Diagnosing and fixing CPU triple faults.
- Verifying the far jump into 32-bit protected mode.
- Debugging the kernel entry point using GDB.
- Confirming the Assembly-to-C kernel transition.
- Inspecting VGA memory to verify hardware output.

## Tools Used

- NASM
- GCC
- LD
- QEMU
- GDB
- xxd
- objdump
- readelf

## Example GDB Verification

The kernel entry point was verified using GDB.

```text
_start
    |
    ▼
call kernel_main()
```

After entering the C kernel, VGA memory inspection confirmed the expected output:

```text
0xB8000

T
O
S
```

This verified that the custom bootloader successfully transferred execution through:

```text
BIOS → Assembly → Protected Mode → C Kernel
```

---

# Project Structure

```
TanishOS/
│
├── boot/
│   ├── stage1.asm        # BIOS boot sector (512 bytes)
│   ├── stage2.asm        # Second-stage bootloader
│   └── gdt.asm           # Global Descriptor Table setup
│
├── kernel/
│   └── kernel.c          # Main C kernel
│
├── include/
│   └──                  # Kernel header files
│
├── build/
│   └──                  # Generated binaries and disk images
│
├── docs/
│   └──                  # Development documentation
│
├── archive/
│   └──                  # Previous experiments and debugging versions
│
├── Makefile             # Automated build process
│
├── bochsrc.txt          # Bochs emulator configuration
│
└── README.md
```

The repository is divided into bootloader components, kernel implementation, build artifacts, and development documentation.

---

# Build Instructions

## Requirements

Install:

- NASM
- GCC
- Binutils
- QEMU

## Clone Repository

```bash
git clone <repository-url>

cd TanishOS
```

## Build

```bash
make
```

## Run

```bash
qemu-system-x86_64 -drive format=raw,file=build/tanishos.img
```

---

# Boot Process Explanation

TanishOS follows a multi-stage boot process where each stage prepares the system for the next execution environment.

## Stage 1 Bootloader

The BIOS loads the first 512 bytes of the disk into memory at:

```text
0x7C00
```

Responsibilities:

- Execute immediately after BIOS startup.
- Validate the boot signature `0xAA55`.
- Load Stage 2 bootloader into memory.

---

## Stage 2 Bootloader

The second stage prepares the CPU for kernel execution.

Responsibilities:

- Enable the A20 line.
- Load the Global Descriptor Table (GDT).
- Switch the CPU into 32-bit protected mode.
- Load the kernel from disk.

---

## Kernel

After entering protected mode:

- Assembly entry point `_start` begins execution.
- Stack is initialized.
- Control is transferred to `kernel_main()`.
- Kernel writes directly to VGA memory at:

```text
0xB8000
```

---

# Future Roadmap

Possible future improvements:

- Keyboard driver
- Interrupt Descriptor Table (IDT)
- Programmable Interrupt Controller (PIC)
- Basic command shell
- Memory management experiments
- Simple filesystem support

---

# Screenshots

## Screenshots

### TanishOS Boot

![TanishOS Boot](screenshots/TanishOS_boot.png)

### Build Process

![Build Success](screenshots/build_success.png)

### Project Structure

![Project Tree](screenshots/Project_Tree.png)

---

# License

This project is created for educational purposes to understand operating system fundamentals, x86 architecture, and low-level systems programming.
