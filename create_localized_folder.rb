#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
# Mac環境でローカライズドなフォルダーを作成する
# http://d.hatena.ne.jp/Watson/20081213/1229137674
require 'kconv'
require 'nkf'

folder_en = ""
folder_ja = ""

ARGV.size.times do
  case ARGV.shift
  when "-e"
    folder_en = ARGV.shift
  when "-j"
    folder_ja = Kconv.toutf8(ARGV.shift)
  end
end

if(folder_en == "" or folder_ja == "")
  puts "Usage: #{$0} -e test -j テスト"
  exit
end

Dir::mkdir("#{folder_en}.localized/")
Dir::mkdir("#{folder_en}.localized/.localized")

File.open("#{folder_en}.localized/.localized/ja.strings", 'w') { |f|
  f.write "\"#{folder_en}\" = \"#{folder_ja}\";"
}

