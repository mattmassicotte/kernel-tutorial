# Rakefile

require 'rake/clean'
require 'fileutils'

# constants
BUILD_DIR = 'build'
ELF32_NASM = 'nasm -felf32'
ELF32_C_COMPILER = 'clang -target i386-linux-gnu'
KERNEL_C_FLAGS = '-ffreestanding -Wall -Wextra'
ELF32_LINKER = 'i386-unknown-linux-gnu-ld'

# base rules
directory BUILD_DIR

# helper functions
def build_dir_name(source)
  File.join('build', File.basename(source)).ext('.o')
end

def objects_for_cmd(objects)
  objects.map { |x| "'#{x}'"}.join(" ")
end
