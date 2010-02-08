#!/usr/local/bin/macruby
# -*- coding: utf-8 -*-
require 'optparse'
require 'rubygems'
require 'hotcocoa/graphics'
include HotCocoa
include Graphics

FILE_FORMAT = {
  "png" => NSPNGFileType,
  "gif" => NSGIFFileType,
  "jpg" => NSJPEGFileType,
  "jpeg" => NSJPEGFileType,
  "tif" => NSTIFFFileType
}

def save(obj, filename)
  properties = {}

  if(filename =~ /.+\.(.+)$/)
    format = FILE_FORMAT[$1.downcase]

    bitmapRep = NSBitmapImageRep.alloc.initWithCIImage(obj.ciimage)
    blob = bitmapRep.representationUsingType(format, properties:properties)
    blob.writeToFile(filename, atomically:true)
  end
end

width = height  = 0
input_filename  = nil
output_filename = nil

opts = OptionParser.new do |opts|
  opts.on('-i ', String, 'Input FileName') do |v|
    input_filename = v
  end

  opts.on('-o ', String, 'Output FileName') do |v|
    output_filename = v
  end

  opts.on('-s ', String, 'Specified with size to resize. width=300, height=200, -s 300x200') do |v|
    if(v =~ /(.+)x(.+)/)
      width  = $1.to_i
      height = $2.to_i
    end
    width  ||= 100
    height ||= 100
  end
end
opts.parse!(ARGV)

if(input_filename == nil or output_filename == nil)
  puts opts.help
  exit
end

image = Image.new(input_filename)
image.resize(width, height)
save(image, output_filename)
