$: << File.join(File.dirname(__FILE__),'app')

require "rubygems"
require "spec"
require 'mocha'

Spec::Runner.configure do |config|
  config.mock_with :mocha
end
