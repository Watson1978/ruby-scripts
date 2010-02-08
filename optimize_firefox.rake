# -*- coding: utf-8 -*-
# Firefoxが使うProfileディレクトリに存在する
# sqliteファイルをvaccum、reindexするためのRakefile。

# Usage: rake -f optimize_firefox.rake

# profiles.iniが存在するパスを指定する
PROFILE_BASE_DIR = "~/Library/Application Support/Firefox/"
# Sqlite3のパスを指定する
SQLITE = "/usr/bin/sqlite3"

task :default do
  basedir = File.expand_path(PROFILE_BASE_DIR)

  pdirs = get_profile_dirs(basedir)
  pdirs.each do |dir|
    puts "==== #{dir} ===="
    files = Dir.glob(File.join("#{basedir}/#{dir}", '**/*.sqlite'))
    files.each do |file|
      optimize(file)
    end
  end
end

def get_profile_dirs(basedir)
  # profiles.iniからディレクトリパスを取得
  profiles = []

  File.open("#{basedir}/profiles.ini", "r") { |f|
    f.each_line do |line|
      if(line =~ /Path=(.+)/)
         profiles << $1
       end
    end
  }
  return profiles
end

def optimize(file)
  file.gsub!(/ /, '\ ')
  puts "**** [#{File.basename(file)}] ****"

  sh "#{SQLITE} #{file} vacuum"
  sh "#{SQLITE} #{file} reindex"

  puts
end
