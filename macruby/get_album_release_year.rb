# -*- coding: utf-8 -*-
require 'uri'
require 'open-uri'

artist = ARGV[0]
album  = ARGV[1]

def get_track_year(url)
  source = ""
  open(url) do |res|
    source = res.read
  end

  if(source =~ /<li><b>CD<\/b>  \(([^\/]+)/m)
    return $1.to_i
  end

  return ""
end

def search_url(artist, album)
  # アーティスト+アルバム名でヒットするAmazonのページを検索
  url = URI.escape("http://www.google.co.jp/search?q=site:www.amazon.co.jp \"#{artist}\" \"#{album}\"")
  source = ""
  open(url) do |res|
    source = res.read
  end

  if(source =~ /<div id=ires><ol><li class=g><h3 class=\"r\"><a href=\"([^\"]+)/)
    # トップヒットしたURLを返す
    return $1
  end

  return nil
end


url  = search_url(artist, album)
year = get_track_year(url) if(url)
year ||= ""

puts year

