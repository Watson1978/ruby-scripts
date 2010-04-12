#!/usr/local/bin/macruby
# -*- coding: utf-8 -*-
framework 'Cocoa'
framework 'ApplicationServices'

# 無限大になるような範囲で適当に定義
CGRectInfinite = CGRect.new([-2.0e+500, -2.0e+500], [2.0e+500, 2.0e+500]) unless defined?(CGRectInfinite)

class ScreenCapture
  def fullScreen(filename = nil)
    filename ||= "#{Time.now.strftime('%Y-%m-%d-%H%M%S')}.png"

    rect = NSScreen.mainScreen.frame()
    window = NSWindow.alloc.initWithContentRect(rect, 
                                                styleMask:NSBorderlessWindowMask,
                                                backing:NSBackingStoreNonretained,
                                                defer:false)
    contentView = window.contentView()
    image = CGWindowListCreateImage(CGRectInfinite, KCGWindowListOptionOnScreenOnly, KCGNullWindowID, KCGWindowImageDefault)

    save(image, filename)
  end

  def save(image, filename)
    bitmapRep = NSBitmapImageRep.alloc.initWithCGImage(image)
    blob = bitmapRep.representationUsingType(NSPNGFileType, properties:nil)
    blob.writeToFile(filename, atomically:true)
  end
  private :save
end

app = NSApplication.sharedApplication
screenCapture = ScreenCapture.new
screenCapture.fullScreen()
