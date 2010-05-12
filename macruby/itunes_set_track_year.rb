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

def set_track_year(tracks, artist, album, year)
  # 指定されたアーティストとアルバム名に一致するトラックにリリース年を設定
  tracks.each do |track|
    if((track.artist == artist) && (track.album == album) && (track.year.to_i == 0))
      5.times do 
        # ときどき設定出来ない場合があるようなので、リトライしながら設定する
        track.year = year
        
        if(track.year == year); break; end
        sleep(0.5)
      end
      puts "#{track.artist} - #{track.album} : #{track.year} : #{year}"
    end

  end
end

playlist = itunes.sources["ライブラリ"].userPlaylists[PLAYLIST]
playlist.tracks.each do |track|
  if((track.artist != "") && (track.album != "") && (track.year.to_i ==  0))
    year = 0
    IO.popen("ruby ./get_album_release_year.rb \"#{track.artist}\" \"#{track.album}\"") { |io|
      year = io.gets.to_i
    }

    if(year > 0)
      # トラックに年を設定
      set_track_year(playlist.tracks, track.artist, track.album, year)
    end
  end
end
