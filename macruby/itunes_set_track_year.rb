#!/usr/local/bin/macruby
# -*- coding: utf-8 -*-
require 'pp'
framework 'Foundation'
framework 'ScriptingBridge'

PLAYLIST = ARGV[0]
unless(PLAYLIST)
  puts "指定されたプレイリストの各トラックにリリース年を設定します"
  puts "Note:  あらかじめ、アーティスト名とアルバム名が各トラックに設定されている必要があります"
  puts ""
  puts "USAGE: macruby itunes_set_track_year.rb プレイリスト名"

  exit
end

unless(File.exist?("iTunes.bridgesupport"))
  system("sdef /Applications/iTunes.app | sdp -fh --basename iTunes")
  system("gen_bridge_metadata -c '-I.' iTunes.h > iTunes.bridgesupport")
end

itunes = SBApplication.applicationWithBundleIdentifier("com.apple.itunes")
load_bridge_support_file 'iTunes.bridgesupport'
itunes.run
 
class SBElementArray
  def [](value)
    self.objectWithName(value)
  end
end

playlist = itunes.sources["ライブラリ"].userPlaylists[PLAYLIST]
playlist.tracks.each do |track|
  year = 0
  if(track.year.to_i > 0)
    year =  track.year
  else
    if((track.artist != "") && (track.album != ""))
      IO.popen("ruby ./get_album_release_year.rb \"#{track.artist}\" \"#{track.album}\"") { |io|
        year = io.gets.to_i
      }

      if(year > 0)
        # トラックに年を設定
        track.year = year
      end
      puts "#{track.artist} - #{track.album} : #{track.year}"
    end
  end
end
