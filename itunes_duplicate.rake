# -*- coding: utf-8 -*-
# iTunesライブラリに重複登録されたファイルを削除する
# http://d.hatena.ne.jp/Watson/20081215/1229299017
require 'fileutils'

ITUNES_LIBRARY_DIR    = '/Users/watson/Music/iTunes/iTunes Music'
TRASH_DIR             = '/Users/watson/Trash'
ITUNES_DUPLICATE_LIST = 'itunes_duplicate_files.txt'

task :listup do
  all_files = Dir.glob(File.join(ITUNES_LIBRARY_DIR, '**/*'))
  all_files.delete_if {|f| File.directory? f}

  File.open(ITUNES_DUPLICATE_LIST, 'w') { |fout|
    all_files.each do |file|
      if(file =~ /(.+) [1-3]\.(mp3|m4a)$/) # 同じファイルが3つくらいまで？
        # 拡張子の前に数字が記載されているファイル名は、重複登録されたファイルっぽい
        # ex)
        #    xxxx/01 hogehoge.m4a
        #    xxxx/01 hogehoge 1.m4a   ← 重複登録されたものかも
        if(Dir.glob("#{$1}\.#{$2}") != nil) 
          # 数字を取り除いたファイルが存在したら、そのファイルは重複登録されたものかも
          fout.puts(file)
        end
      end
    end
  }
end

task :remove do
  # 重複登録されたファイルを TRASH_DIR へ移動
  File.open(ITUNES_DUPLICATE_LIST, 'r') { |fin|
    fin.each do |file|
      file = file.chomp
      dest = file.sub(/^#{ITUNES_LIBRARY_DIR}/, TRASH_DIR)
      folder = File.dirname(dest)
      mkdir_p(folder) unless(File.exists?(folder))
      FileUtils.move(file, dest)
    end
  }
end

def mkdir_p(dir)
  unless(File.exists?(parent = File.dirname(dir)))
    mkdir_p(parent)
  end
  Dir.mkdir(dir)
end

