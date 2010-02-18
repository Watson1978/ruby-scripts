#!/usr/local/bin/macruby
# -*- coding: utf-8 -*-
framework "Cocoa"
framework "CoreLocation"

class AppController
  def initialize()
    @app = NSApplication.sharedApplication
    delegate = Location.new
    @app.delegate = delegate
    @app.run
  end
end

class Location
  def initialize()
    @manager = CLLocationManager.alloc.init
    @manager.delegate = self
    @manager.startUpdatingLocation
  end

  def locationManager(manager, 
                      didUpdateToLocation:new_location,
                      fromLocation:old_location)
#     NSLog("Location: #{new_location.description}");

#     なぜかcrashする。iPhone SDKからアクセスしないとだめ？
#     @latitude  = new_location.coordinate.latitude
#     @longitude= new_location.coordinate.longitude
    if(new_location.description =~ /<(.+), (.+)>/)
      @latitude  = $1
      @longitude = $2
       
      @manager.stopUpdatingLocation
      self.openGoogleMaps()
      NSApplication.sharedApplication.terminate(nil)
     end
  end

  def locationManager(manager,
                      didFailWithError:error)
    puts "Error."
    NSApplication.sharedApplication.terminate(nil)
  end

  def openGoogleMaps()
    system("open 'http://maps.google.co.jp/maps?q=#{@latitude},#{@longitude}'")
  end
end

AppController.new
