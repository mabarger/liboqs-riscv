# SPDX-License-Identifier: MIT

# How to use:
# TODO

set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR riscv32)
set(CMAKE_CROSSCOMPILING ON)

set(CMAKE_C_COMPILER riscv64-linux-gnu-gcc)
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -mabi=ilp32 -march=rv32imac_zicsr_zifencei -gdwarf-4 -nostdlib")
set(CMAKE_CROSSCOMPILING_EMULATOR "qemu-system-riscv32")
