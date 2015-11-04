# Rakefile

require 'rake/clean'
require 'fileutils'

# import directly, instead of via 'rakelib' to ensure correct ordering
import 'rake/helpers.rake'
import 'rake/iso.rake'
import 'rake/grub.rake'
import 'rake/multiboot.rake'
#import 'rake/basic_kernel.rake'
#import 'rake/more_multiboot_kernel.rake'
import 'rake/kernel.rake'

# constants
BUILD_DIR = 'build'
ELF32_NASM = 'nasm -felf32'
ELF32_C_COMPILER = 'clang -target i386-linux-gnu'
KERNEL_C_FLAGS = '-ffreestanding -Wall -Wextra'
ELF32_LINKER = 'i386-unknown-linux-gnu-ld'

# base rules
directory BUILD_DIR
