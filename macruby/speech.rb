#!/usr/bin/env macruby
# -*- coding: utf-8 -*-
require 'optparse'
framework 'AppKit'

class Speech
  def initialize()
    @speech = NSSpeechSynthesizer.alloc.initWithVoice(nil)
    @speech.delegate = self
  end

  def options=(options)
    @options = options

    if(@options[:voice])
      voice = ("com.apple.speech.synthesis.voice." + @options[:voice].capitalize)
      @speech.setVoice(voice)
    end
  end

  def speech(text)
    if(@options[:output])
      url = NSURL.alloc.initWithString(@options[:output])
      @speech.startSpeakingString(text, toURL:url)
    else 
      @speech.startSpeakingString(text)
    end
  end

  def speechSynthesizer(sender, didFinishSpeaking:success)
    NSApplication.sharedApplication.terminate(nil)
  end

end

options = {}
opts = OptionParser.new do |opt|
  opt.banner = "Usage: #$0 [options] text"

  opt.on('--voice=[VOICE]', String, 'Specify voice') do |v|
    options[:voice] = v
  end

  opt.on('--output=[FILENAME]', String, 'Specify output filename (AIFF)') do |v|
    options[:output] = v
  end

  opt.on_tail('--help', 'Display this message and exit') do
    puts opt
    exit
  end
end
opts.parse!

text = ARGV.first
unless(text)
  puts opts
  exit
end

app = NSApplication.sharedApplication
delegate = Speech.alloc.init
app.delegate = delegate
delegate.options = options
delegate.speech(text)
app.run
