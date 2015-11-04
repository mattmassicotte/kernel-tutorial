ISO_OUTPUT = File.join(BUILD_DIR, 'kernel.iso')
ISO_FILES_DIR = File.join(BUILD_DIR, 'isofiles')
ISO_BOOT_DIR = File.join(ISO_FILES_DIR, 'boot')

directory ISO_FILES_DIR => BUILD_DIR

GRUB_ISO_BOOT_PATH = '/boot/grub/stage1'

CLOBBER.include(ISO_OUTPUT)
CLEAN.include(ISO_FILES_DIR)

namespace :iso do
  desc 'Build a bootable GRUB ISO image'
  task :grub => ISO_FILES_DIR do
    sh("xorriso -outdev '#{ISO_OUTPUT}' -blank as_needed -map '#{ISO_FILES_DIR}' / -boot_image grub bin_path=#{GRUB_ISO_BOOT_PATH}")
  end
end
