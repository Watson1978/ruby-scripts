require 'processor.rb'

SRC_DIR  = './org'
DEST_DIR = './new'

all_files = Dir.glob(File.join(SRC_DIR, '**/*'))
all_files.delete_if {|f| File.directory? f}

all_files.each_with_index { |file, index|
  p = Processor.new OSX::CIImage.from(file)
  p.resize(200, 150)
  p.render do |result|
    result.save("#{DEST_DIR}/#{index}.jpg", OSX::NSJPEGFileType)
  end
}
