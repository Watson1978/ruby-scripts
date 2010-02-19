#!/usr/local/bin/macruby
# -*- coding: utf-8 -*-
# FILENAME: exif.rb
framework "Cocoa"
framework "ApplicationServices"

in_filename  = ARGV[0]
out_filename = ARGV[1]

url = NSURL.fileURLWithPath(in_filename)
image_src = CGImageSourceCreateWithURL(url, nil);

metadataRef = CGImageSourceCopyPropertiesAtIndex(image_src, 0, nil);
metadata = metadataRef.mutableCopy
# view Exif Data
#p metadata

new_image = NSMutableData.alloc.init
image_dst = CGImageDestinationCreateWithData(new_image, CGImageSourceGetType(image_src), 1, nil)

exif = {}
exif = metadata["{Exif}"]
exif["UserComment"] = "test12345!!!!!"
exif["DateTimeOriginal"] = "2010:01:01 00:00:00"

gps = {}
gps["MapDatum"] = "WGS-84"

metadata["{Exif}"] = exif
metadata["{GPS}"]  = gps

CGImageDestinationAddImageFromSource(image_dst, image_src, 0, metadata);
if(CGImageDestinationFinalize(image_dst))
  new_image.writeToFile(out_filename, atomically:true);
end
