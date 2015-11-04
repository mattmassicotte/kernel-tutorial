GRUB_FLOPPY = File.join(BUILD_DIR, 'grub-floppy.img')
GRUB_ISO_BOOT_DIR = File.join(ISO_FILES_DIR, 'boot')
GRUB_ISO_GRUB_DIR = File.join(GRUB_ISO_BOOT_DIR, 'grub')
GRUB_KERNEL_BIN = File.join(BUILD_DIR, 'kernel.bin')

# grub source paths
GRUB_STAGE1_FILE = 'bootloader/grub-0.97-binaries/stage1'
GRUB_ISO_STAGE1_FILE = 'bootloader/grub-0.97-binaries/iso9660_stage1_5'
GRUB_STAGE2_FILE = 'bootloader/grub-0.97-binaries/stage2'

GRUB_ISO_MENU_PATH = File.join(GRUB_ISO_GRUB_DIR, 'menu.lst')
GRUB_ISO_DATA_FILE_PATH = File.join(GRUB_ISO_BOOT_DIR, 'data_file')
GRUB_ISO_STAGE1_PATH = File.join(GRUB_ISO_GRUB_DIR, 'stage1')
GRUB_ISO_STAGE2_PATH = File.join(GRUB_ISO_GRUB_DIR, 'stage2')

CLOBBER.include(GRUB_FLOPPY)

file GRUB_FLOPPY => BUILD_DIR do |name|
  sh("dd if=#{GRUB_STAGE1_FILE} of=#{name} bs=512 count=1")
  sh("dd if=#{GRUB_STAGE2_FILE} of=#{name} bs=512 seek=1")
end

directory GRUB_ISO_BOOT_DIR => ISO_FILES_DIR
directory GRUB_ISO_GRUB_DIR => ISO_FILES_DIR

file GRUB_ISO_MENU_PATH => GRUB_ISO_GRUB_DIR do
  FileUtils.cp('bootloader/menu.lst', GRUB_ISO_GRUB_DIR)
end

file GRUB_ISO_DATA_FILE_PATH => GRUB_ISO_BOOT_DIR do
  FileUtils.cp('bootloader/data_file', GRUB_ISO_BOOT_DIR)
end

file GRUB_ISO_STAGE1_PATH => GRUB_ISO_GRUB_DIR do
  FileUtils.cp(GRUB_ISO_STAGE1_FILE, GRUB_ISO_STAGE1_PATH)
end

file GRUB_ISO_STAGE2_PATH => GRUB_ISO_GRUB_DIR do
  FileUtils.cp(GRUB_STAGE2_FILE, GRUB_ISO_STAGE2_PATH)
end

namespace :grub do
  desc 'Build a floppy image with only GRUB installed'
  task :floppy => GRUB_FLOPPY

  desc 'Copy kernel.bin into the iso structure'
  task :kernel => GRUB_ISO_BOOT_DIR do
    FileUtils.cp(GRUB_KERNEL_BIN, GRUB_ISO_BOOT_DIR)
  end

  desc 'Build grub-bootable ISO with no kernel'
  task :basic_iso => [GRUB_ISO_STAGE1_PATH, GRUB_ISO_STAGE2_PATH] do
    Rake::Task['iso:grub'].invoke
  end

  desc 'Build full grub-bootable ISO with kernel.bin'
  task :prepare_iso => [:kernel, GRUB_ISO_MENU_PATH, GRUB_ISO_DATA_FILE_PATH, GRUB_ISO_STAGE1_PATH, GRUB_ISO_STAGE2_PATH] do
    Rake::Task['iso:grub'].invoke
  end
end
