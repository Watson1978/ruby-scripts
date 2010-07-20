#!/usr/local/bin/macruby
# -*- coding: utf-8 -*-
require "rubygems"
require "hotcocoa"

# ステータスバーに表示するアイコン
ICON = "icon-11.png"
# クリックされたときに表示するアイコン
ICON2 = ICON

class Application
  include HotCocoa

  def start
    @app = application(:name => "sample", :delegate => self)
    @status = status_item
    set_status_menu()
    @app.run()
  end

  def set_status_menu
    @menu = status_menu()
    @status.menu = @menu
    @status.title = "Hello" # アイコンの横にタイトルを付ける
    @status.image = image(:file => ICON, :size => [ 17, 17 ])           if(File.exists?(ICON))
    @status.alternateImage = image(:file => ICON2, :size => [ 17, 17 ]) if(File.exists?(ICON2))
    @status.setHighlightMode(true)
  end

  def status_menu
    menu(:delegate => self) do |status|
      status.submenu(:apple) do |apple|
        apple.item(:about, :title => "About #{NSApp.name}")
        apple.separator()
        apple.item(:preferences, :key => ",").setState(NSOnState) # チェックを付ける
        apple.separator()
        apple.submenu(:services)
        apple.separator()
        apple.item(:hide, :title => "Hide #{NSApp.name}", :key => "h")
        apple.item(:hide_others, :title => "Hide Others", :key => "h", :modifiers => [:command, :alt])
        apple.item(:show_all, :title => "Show All")
        apple.separator()
        apple.item(:quit, :title => "Quit #{NSApp.name}", :key => "q")
      end
      status.separator()
      status.item("Quit", :key => "q", :on_action => Proc.new { @app.terminate(self) })
    end
  end
end

Application.new.start
