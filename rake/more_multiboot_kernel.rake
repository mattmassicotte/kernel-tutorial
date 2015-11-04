MORE_MULTIBOOT_KERNEL_SOURCE = '32-bit-kernel/more_multiboot_kernel.c'
MORE_MULTIBOOT_KERNEL_OBJECT = File.join(BUILD_DIR, 'more_multiboot_kernel.o')
MORE_MULTIBOOT_KERNEL = File.join(BUILD_DIR, 'more_multiboot_kernel.bin')
MORE_MULTIBOOT_KERNEL_LINKER_SCRIPT = '32-bit-kernel/kernel.ld'
MORE_MULTIBOOT_KERNEL_OBJECTS = [MULTIBOOT_OBJECTS, MORE_MULTIBOOT_KERNEL_OBJECT].flatten

CLEAN.include(MORE_MULTIBOOT_KERNEL_OBJECT)
file MORE_MULTIBOOT_KERNEL_OBJECT => [MORE_MULTIBOOT_KERNEL_SOURCE, BUILD_DIR] do |name|
  sh("#{ELF32_C_COMPILER} #{KERNEL_C_FLAGS} -c '#{MORE_MULTIBOOT_KERNEL_SOURCE}' -o '#{name}'")
end

CLOBBER.include(MORE_MULTIBOOT_KERNEL)
file MORE_MULTIBOOT_KERNEL => [MORE_MULTIBOOT_KERNEL_OBJECTS, MORE_MULTIBOOT_KERNEL_LINKER_SCRIPT].flatten do |name|
  objects = objects_for_cmd(MORE_MULTIBOOT_KERNEL_OBJECTS)
  sh("#{ELF32_LINKER} -T #{MORE_MULTIBOOT_KERNEL_LINKER_SCRIPT} -o '#{name}' #{objects}")
end

namespace :kernel do
  namespace :more_multiboot do
    desc 'Compile the more_multiboot 32-bit kernel object'
    task :compile => MORE_MULTIBOOT_KERNEL_OBJECT

    desc 'Compile and link the more_multiboot 32-bit kernel'
    task :build => MORE_MULTIBOOT_KERNEL

    desc 'Build the more_multiboot 32-bit kernel ISO'
    task :iso => [MORE_MULTIBOOT_KERNEL, 'grub:iso_directories'] do
      FileUtils.cp(MORE_MULTIBOOT_KERNEL, GRUB_KERNEL)
      FileUtils.cp('bootloader/menu.lst', GRUB_ISO_GRUB_DIR)
      FileUtils.cp('bootloader/data_file', GRUB_ISO_BOOT_DIR)

      Rake::Task['grub:iso'].invoke
    end
  end
end
