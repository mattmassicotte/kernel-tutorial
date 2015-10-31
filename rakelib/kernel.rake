BASIC_KERNEL_SOURCE = '32-bit-kernel/kernel.c'
BASIC_KERNEL_OBJECT = File.join(BUILD_DIR, 'basic-kernel.o')
BASIC_KERNEL = File.join(BUILD_DIR, 'basic-kernel.bin')
BASIC_KERNEL_LINKER_SCRIPT = '32-bit-kernel/kernel.ld'
BASIC_KERNEL_MULTIBOOT_OBJECTS = ['multiboot_header.o', 'multiboot_entry.o'].map { |x| File.join(BUILD_DIR, x) }
BASIC_KERNEL_OBJECTS = [BASIC_KERNEL_MULTIBOOT_OBJECTS, BASIC_KERNEL_OBJECT].flatten

CLEAN.include(BASIC_KERNEL_OBJECT)
file BASIC_KERNEL_OBJECT => [BASIC_KERNEL_SOURCE, BUILD_DIR] do |name|
  sh("#{ELF32_C_COMPILER} #{KERNEL_C_FLAGS} -c '#{BASIC_KERNEL_SOURCE}' -o '#{name}'")
end

CLOBBER.include(BASIC_KERNEL)
file BASIC_KERNEL => [BASIC_KERNEL_OBJECTS, BASIC_KERNEL_LINKER_SCRIPT].flatten do |name|
  objects = objects_for_cmd(BASIC_KERNEL_OBJECTS)
  sh("#{ELF32_LINKER} -T #{BASIC_KERNEL_LINKER_SCRIPT} -o '#{name}' #{objects}")
end

namespace :kernel do
  namespace :basic do
    desc 'Compile the basic 32-bit kernel object'
    task :compile => BASIC_KERNEL_OBJECT

    desc 'Compile and link the basic 32-bit kernel'
    task :build => BASIC_KERNEL
  end
end
