# -*- coding: utf-8 -*-
# MacPorts で active になっていないものを強制的にアンインストールする

# Usage: rake -f port.rake

PORT_INSTALLED_FILE = "port-installed.txt"

task :installed do
  sh "port installed > #{PORT_INSTALLED_FILE}"
end

task :force_uninstall => :installed do
  File.open(PORT_INSTALLED_FILE, 'r') { |f|
    f.each do |line|
      if((line =~ /.+ @.+/) &&
         !(line =~ /(active)/))
        sh "port uninstall -f #{line}"
      end

    end
  }
end

