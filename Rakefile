desc 'Default task: run all tests'

require 'spec/rake/spectask'

task :default => [:spec]

# Load rake tasks in ./tasks/*.rake
Dir.glob(File.expand_path(File.join(File.dirname(__FILE__), "tasks", "*.rake"))).each { |f| load f }
