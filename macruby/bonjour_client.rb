#!/usr/local/bin/macruby
# -*- coding: utf-8 -*-
# filename: bonjour_client.rb
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
    @browser = NSNetServiceBrowser.alloc.init()
    @browser.delegate = self
    @browser.searchForServicesOfType("_test._tcp", inDomain:"")
  end

  # delegate for searchForServicesOfType
  def netServiceBrowser(netServiceBrowser,
                        didFindService:netService,
                        moreComing:moreServicesComing)
    @browser.stop
    netService.delegate = self
    netService.resolveWithTimeout(1)
  end

  # delegate for resolveWithTimeout
  def netServiceDidResolveAddress(netService)
    string = netService.addresses[0].description
    string = string.split(' ')[1]

    addr = ""
    i = 0
    4.times do
      addr = addr + string[i..(i+1)].hex.to_s
      addr = addr + "." if(i < 6)
      i = i + 2
    end

    puts "Peer Address  : #{addr}"
    puts "Peer Host     : #{netService.hostName}"
    puts "Domain        : #{netService.domain}"
    puts "Service Port  : #{netService.port}"
    puts "Service Type  : #{netService.type}"

    netService.stop()
    NSApplication.sharedApplication.terminate(nil)
  end
end

AppController.new()
