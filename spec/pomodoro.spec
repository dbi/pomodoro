require 'pomodoro'

describe Pomodoro do

  it "it should be possible to give an relative path to and icon" do
    p = Pomodoro.new("desc", :icon => "clock.png")
    p.icon.should == File.join(POMODORO_HOME, "clock.png")
  end
  
  it "should be possible to give an absolute path to an icon" do
    p = Pomodoro.new("desc", :icon => File.join(POMODORO_HOME, "clock.png"))
    p.icon.should == File.join(POMODORO_HOME, "clock.png")
  end
  
  it "should have a default icon" do
    Pomodoro.new("desc").icon.should == File.join(POMODORO_HOME, "tomato.png")
  end
  
  it "should add extension .png if none [neither png nor gif] is given (relative path)" do
    p = Pomodoro.new("desc", :icon => File.join(POMODORO_HOME, "clock"))
    p.icon.should == File.join(POMODORO_HOME, "clock.png")
  end

end

