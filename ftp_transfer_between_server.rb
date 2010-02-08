#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
# FTPサーバ間でファイル転送を行う
require "net/ftp"

#----------------------------------------
# 送信側
SEND_HOST = "192.168.1.1"
SEND_USER = "hoge"
SEND_PASSWORD = "aaa"
# 受信側
RECV_HOST = "192.168.1.2"
RECV_USER = "fuga"
RECV_PASSWORD = "bbbb"
#----------------------------------------

class CFTP < Net::FTP
  def clear_response
    begin
      @sock.readline
    rescue
    end
  end
end

def transfer_between_server(send, recv, file)
  # データコネクションの準備
  string = recv.sendcmd("PASV")
  if(string =~ /\((.+)\)/)
    address = $1
  else
    puts "***** #{string}"
    raise "PASV mode error."
  end
  send.sendcmd("PORT #{address}")

  # ファイル転送
  send.sendcmd("RETR #{file}")
  recv.sendcmd("STOR #{file}")

  # ファイル転送時に2行分のレスポンスが発生する
  # -> RETR, STORコマンド発行に対するレスポンス + データ転送完了レスポンス
  # sendcmd では1行分のレスポンスしか扱わないため、残骸を消す必要がある
  send.clear_response
  recv.clear_response
end

send = CFTP.new(SEND_HOST, SEND_USER, SEND_PASSWORD)
recv = CFTP.new(RECV_HOST, RECV_USER, RECV_PASSWORD)
send.debug_mode = true
recv.debug_mode = true

send.nlst.each do |file|
  if(file =~ /.+\.rb$/)
    puts "--[#{file}]--"
    begin
      transfer_between_server(send, recv, file)
    rescue
      break
    end
  end
end

recv.close()
send.close()
