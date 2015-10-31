MULTIBOOT_SOURCES = FileList['32-bit-kernel/multiboot_*.asm']
MULTIBOOT_OBJECTS = FileList.new

MULTIBOOT_SOURCES.each do |source|
  output = build_dir_name(source)

  CLEAN.include(output)
  MULTIBOOT_OBJECTS.include(output)

  file output => [source, BUILD_DIR] do |name|
    sh("#{ELF32_NASM} '#{source}' -o '#{name}'")
  end
end

namespace :multiboot do
  desc 'Assemble the multiboot files'
  task :compile => MULTIBOOT_OBJECTS
end
