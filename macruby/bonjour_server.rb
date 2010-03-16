#!/usr/local/bin/macruby
# -*- coding: utf-8 -*-
# filename: bonjour_server.rb
framework "Cocoa"
framework "Foundation"

class AppController
  def initialize()
    @app = NSApplication.sharedApplication
    delegate = Bonjour.new
    @app.delegate = delegate
    @app.run
  end
end

class Bonjour
  def initialize()
    @netservice = NSNetService.alloc.initWithDomain("", type:"_test._tcp", name:"", port:"9999")
    @netservice.delegate = self
    @netservice.publish()
  end

  # delegate for publish
  def netServiceWillPublish(sender)
    p "netServiceWillPublish"
  end

  # delegate for publish
  def netServiceDidPublish(sender)
    p "netServiceDidPublish"
  end
end

AppController.new()
