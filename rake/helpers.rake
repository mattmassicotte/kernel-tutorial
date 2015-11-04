def build_dir_name(source)
  File.join('build', File.basename(source)).ext('.o')
end

def objects_for_cmd(objects)
  objects.map { |x| "'#{x}'"}.join(" ")
end
