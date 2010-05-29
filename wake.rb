# -*- coding: utf-8 -*-
require "socket"

module WakeOnLan
  def wake(mac_addr)
    sock = UDPSocket.open
    sock.setsockopt(Socket::SOL_SOCKET,Socket::SO_BROADCAST, 1)

    mac = mac_addr.split(":").map{|x| sprintf("%02x", x.hex)}

    msg = 0xff.chr * 6
    msg = msg + mac.pack("H*H*H*H*H*H*") * 16

    sock.send(msg, 0, "255.255.255.255", "discard")
    sock.close
  end
  module_function :wake
end

if $0 == __FILE__
  WakeOnLan.wake("0:1b:63:96:5:e9")
end
