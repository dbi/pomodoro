#!/usr/bin/env ruby

POMODORO_HOME = File.dirname(File.symlink?(__FILE__) ? File.readlink(__FILE__) : __FILE__)

require "osx/cocoa"
include OSX
require "#{POMODORO_HOME}/growl"

class Pomodoro
  
  DEFAULT_SETTINGS = {
    :debug    => false,   # will speed up the pomodoro
    :duration => 25,      # duration of a pomodoro (minutes)
    :color    => true,    # exit messages have colored output (I sometimes found them hard to notice)
    :sound    => true,     
    :icon     => 'tomato.png'
  }
  
  def initialize(title="unnamed", options={})
    @settings = DEFAULT_SETTINGS.merge options
    @title = title
    @counter = 0
    detect_color

    iconfile = OSX::NSImage.alloc.initWithContentsOfFile icon
    @growl = Growl::Notifier.alloc.initWithDelegate(self)
    @growl.start("Pomodoro Timer", ["started", "completed"], nil, iconfile)
  end
  
  def icon
    icon = @settings[:icon]
    if icon.include? "/"
      icon = @settings[:icon]
    else
      icon = File.join(POMODORO_HOME, @settings[:icon])
    end
    
    if not %w(.png .gif).any? {|ext| icon =~ /#{ext}$/}
      icon = "#{icon}.png"
    end
    icon
  end
  
  def run
    begin
      puts '- Press ctrl+c to abort current pomodoro.'
      puts '- Stop recurring by clicking \'x\' on the "time is up" popup.'
      puts "-" * @settings[:duration]
      pomodoro :run
    
      # Needed to handle growl callbacks.
      NSApplication.sharedApplication
      NSApp.run
    rescue Interrupt
      pomodoro :aborted
    end
  end

  def pomodoro(state)
    case state
      when :run
        pomodoro :started
        wait @settings[:duration]
        pomodoro :completed
      when :started
        @growl.notify(  kind = state.to_s,
                        title = "Pomodoro started",
                        description = "#{@title}",
                        context = nil,
                        sticky = false)
      when :completed
        sound_alarm if @settings[:sound]
        @counter += 1
        @growl.notify(  kind = state.to_s,
                        title = "Time is up!",
                        description = "(click to continue)\n\n#{@title}",
                        context = "restart", 
                        sticky = true)
      when :aborted
        puts " (aborted)"
        exit_pomodoro
      when :finished
        exit_pomodoro
    end
  end
  
  def growl_onClicked(sender, context)
    begin
      if context == "restart"
        sleep 0.8 # about the fadeout animation duration
        pomodoro :run
      end
    rescue Interrupt
      pomodoro :aborted
    end
  end
  
  def growl_onTimeout(sender, context)
    pomodoro :finished
  end
  
  def sound_alarm(frequence=3)
    frequence.times do
      print "\a"
    end
    STDOUT.flush
  end
  
  def wait(minutes)
    minutes.times do
      sleep seconds_per_minute
      print "*"
      STDOUT.flush
    end
    puts
  end
  
  def seconds_per_minute
    @settings[:debug] ? 0.3 : 60
  end
  
  def detect_color
    if @settings[:color]
      begin
        require "rubygems"
        require "redgreen"
      rescue LoadError
        @settings[:color] = false
      end
    end
  end
  
  def exit_pomodoro(message="#{@counter} pomodoro: #{@title}")
    puts @settings[:color] ? "\e[32m#{message}\e[0m" : message
    OSX::NSApplication.sharedApplication.terminate(self)
  end

end

if __FILE__ == $0
  if (ARGV.length > 0)
    if ARGV[0] == "debug"
      Pomodoro.new("debug session", :debug => true, :duratio => 25).run
      return
    end
    opts = {}
    opts[:duration] = ARGV[1].to_i if ARGV.length > 1
    opts[:icon] = ARGV[2] if ARGV.length > 2
    Pomodoro.new(ARGV[0], opts).run
  else
    puts "Usage: pomodoro.rb <description> [duration in minues] [icon]"
  end
end
