#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
# はてなスクリーンショットを更新するためのスクリプト
# サイト更新などにより、はてなブックマークで使用されているサムネイルが古い場合など
# で使用する
require 'rss'
require 'open-uri'

# Configuration
SITE_URI = "http://d.hatena.ne.jp/Watson/"

USER_AGENT = "Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.5; ja-JP-mac; rv:1.9.2) Gecko/20100115 Firefox/3.6"
SCREENSHOT_BASE_URI = "http://screenshot.hatena.ne.jp/redirect?uri="
BOOKMARS_RSS_URI = "http://b.hatena.ne.jp/entrylist?sort=count&url=#{SITE_URI}&mode=rss"

rss = RSS::Parser.parse(BOOKMARS_RSS_URI)
rss.items.each do |item|
  bookmark_uri = item.link

  open("#{SCREENSHOT_BASE_URI}#{bookmark_uri}", "User-Agent" => USER_AGENT) { |res|
    uri = res.base_uri.to_s
    puts bookmark_uri

    if(!(uri =~ /redirect/))
      # スクリーンショットがとられていれば、URIに"redirect"が含まれない

      # http://screenshot.hatena.ne.jp//f/8/7/ ・・・
      #   ↓
      # http://screenshot.hatena.ne.jp/retry/f/8/7/ ・・・
      # としたURIが、スクリーンショットを取り直すためのURI
      uri.sub!(/ne.jp\/\//, "ne.jp/retry/")
      puts uri
      open(uri, "User-Agent" => USER_AGENT) { |t|
        p t.status
      }
      puts ""

      sleep(1)
    else
      puts "** #{SCREENSHOT_BASE_URI}#{bookmark_uri}"
    end
  }
end
