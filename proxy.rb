#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
require 'webrick'
require 'webrick/httpproxy'
require 'uri'

# アクセスを許可するTLD
ALLOW_TLD = {
  "jp"  => true,
  "com" => true,
  "org" => true,
  "net" => true,
}
# アクセスを許可しないURL
DENY_URLS = {
  # domain => url
  "fc2.com" => "video.fc2.com/",
  "2ch.net" => ".*2ch.net/",
  "nicovideo.jp" => ".*nicovideo.jp/",
}

def get_domain(uri)
  # ドメイン文字列を取得
  # www.yahoo.co.jp  -> yahoo.co.jp
  # www.nicovideo.jp -> nicovideo.jp
  host = uri.host.split('.')

  size = host.size
  if (size > 3)
    host = host[size-3 .. size-1]
  elsif(host[-2].length > 2)
    host = host[-2 .. -1]
  end

  return host.join('.')
end

def get_tld(uri)
  # TLD文字列を取得
  host = uri.host.split('.')
  return host[-1]
end

handler = Proc.new() do |req, res|
  if res["content-type"] =~  %r!text/html!
    tld    = get_tld(req.request_uri)
    domain = get_domain(req.request_uri)
    if((!ALLOW_TLD[tld]) or
       (DENY_URLS[domain] != nil and req.unparsed_uri =~ /#{DENY_URLS[domain]}/))
      res.body = "アクセスが許可されていません"
      res.status = 502
    end
  end
end

# プロキシサーバオブジェクトを作る
s = WEBrick::HTTPProxyServer.new(
                                 :BindAddress => '0.0.0.0',
                                 :Port => 8080,

                                 :Logger => WEBrick::Log::new("log.txt", WEBrick::Log::INFO),

                                 :ProxyVia => false,
                                 :ProxyContentHandler => handler,

                                 # 親プロキシ
                                 #:ProxyURI => URI.parse('http://127.0.0.1:8123/')
                                 )

# SIGINT を捕捉する。
Signal.trap('INT') do
  # 捕捉した場合、シャットダウン
  s.shutdown
end

# # デーモン化
# if Process.respond_to? :daemon  # Ruby 1.9
#   Process.daemon
# else                            # Ruby 1.8
#   WEBrick::Daemon.start
# end

# サーバを起動
s.start
