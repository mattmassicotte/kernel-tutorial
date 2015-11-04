KERNEL_LINKER_SCRIPT = '32-bit-kernel/kernel.ld'

BASIC_KERNEL_SOURCE = '32-bit-kernel/kernel.c'
MORE_MULTIBOOT_KERNEL_SOURCE = '32-bit-kernel/more_multiboot_kernel.c'

namespace :kernel do
  namespace :basic do
    desc 'Compile and link the basic 32-bit kernel'
    task :build => MULTIBOOT_OBJECTS do
      sh("#{ELF32_C_COMPILER} #{KERNEL_C_FLAGS} -c '#{BASIC_KERNEL_SOURCE}' -o build/basic_kernel.o")

      objects = objects_for_cmd(['build/basic_kernel.o', MULTIBOOT_OBJECTS].flatten)
      sh("#{ELF32_LINKER} -T #{KERNEL_LINKER_SCRIPT} -o '#{GRUB_KERNEL_BIN}' #{objects}")
    end
  end

  namespace :more_multiboot do
    desc 'Compile and link the more_multiboot 32-bit kernel'
    task :build => MULTIBOOT_OBJECTS do
      sh("#{ELF32_C_COMPILER} #{KERNEL_C_FLAGS} -c '#{MORE_MULTIBOOT_KERNEL_SOURCE}' -o build/more_multiboot_kernel.o")

      objects = objects_for_cmd(['build/more_multiboot_kernel.o', MULTIBOOT_OBJECTS].flatten)
      sh("#{ELF32_LINKER} -T #{KERNEL_LINKER_SCRIPT} -o '#{GRUB_KERNEL_BIN}' #{objects}")
    end
  end

  desc 'Build a kernel ISO'
  task :iso => ['grub:prepare_iso']
end
