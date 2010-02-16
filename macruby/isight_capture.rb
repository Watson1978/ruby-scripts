#!/usr/local/bin/macruby
# -*- coding: utf-8 -*-
framework "Cocoa"
framework "QTKit"

class AppController

  def initialize(filename=nil)
    options = {}
    options[:output] = filename
    options[:output] ||= "#{Time.now.strftime('%Y-%m-%d-%H%M%S')}.jpg"

    @app = NSApplication.sharedApplication
    delegate = Capture.new
    delegate.options = options
    @app.delegate = delegate
    @app.run
  end
end

class Capture
  attr_accessor :capture_view, :options

  def initialize()
    rect = [50, 50, 400, 300]
    win = NSWindow.alloc.initWithContentRect(rect,
                                             styleMask:NSBorderlessWindowMask,
                                             backing:2,
                                             defer:0)
    @capture_view = QTCaptureView.alloc.init

    @session = QTCaptureSession.alloc.init
    win.contentView = @capture_view

    device = QTCaptureDevice.defaultInputDeviceWithMediaType(QTMediaTypeVideo)
    ret = device.open(nil)
    raise "Device open error." if(ret != true)

    input = QTCaptureDeviceInput.alloc.initWithDevice(device)
    @session.addInput(input, error:nil)

    @capture_view.captureSession = @session
    @capture_view.delegate = self

    @session.startRunning
  end

  def applicationDidFinishLaunching(notification)
    while(@captured == nil)
      sleep(0.5)
    end

    save(@captured)
    NSApplication.sharedApplication.terminate(nil)
  end

  def view(view, willDisplayImage:image)
    @captured = image
#ここで画像を保存したかったが、例外が発生するので断念
# -> applicationDidFinishLaunching で画像を保存する
#
#     if(@flag == nil)
#       save(image)
#       @flag = true
#       NSApplication.sharedApplication.terminate(nil)
#     end
  end

  def save(image)
    bitmapRep = NSBitmapImageRep.alloc.initWithCIImage(image)
    blob = bitmapRep.representationUsingType(NSJPEGFileType, properties:nil)
    blob.writeToFile(@options[:output], atomically:true)
  end
end

AppController.new
