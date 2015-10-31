GRUB_FLOPPY = File.join(BUILD_DIR, 'grub-floppy.img')
ISO_FILES_DIR = File.join(BUILD_DIR, 'isofiles')
GRUB_ISO_DIR = File.join(ISO_FILES_DIR, 'boot', 'grub')
GRUB_ISO = File.join(BUILD_DIR, 'grub.iso')

CLOBBER.include(GRUB_FLOPPY)
CLOBBER.include(GRUB_ISO)

file GRUB_FLOPPY => BUILD_DIR do |name|
  sh("dd if=bootloader/grub-0.97-binaries/stage1 of=#{name} bs=512 count=1")
  sh("dd if=bootloader/grub-0.97-binaries/stage2 of=#{name} bs=512 seek=1")
end

directory ISO_FILES_DIR
directory GRUB_ISO_DIR => ISO_FILES_DIR

file GRUB_ISO => [BUILD_DIR, GRUB_ISO_DIR] do |name|
  FileUtils.cp('bootloader/grub-0.97-binaries/iso9660_stage1_5', GRUB_ISO_DIR)
  FileUtils.cp('bootloader/grub-0.97-binaries/stage2', GRUB_ISO_DIR)

  sh("xorriso -outdev '#{name}' -blank as_needed -map '#{ISO_FILES_DIR}' / -boot_image grub bin_path=/boot/grub/iso9660_stage1_5")
end

namespace :grub do
  desc 'Build a floppy image with only GRUB installed'
  task :floppy => GRUB_FLOPPY

  desc 'Build an ISO image with only GRUB installed'
  task :iso => GRUB_ISO
end
