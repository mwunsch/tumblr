require 'tumblr'
require 'webmock/rspec'

WebMock.disable_net_connect!

def fixture_path
   File.expand_path("../fixtures", __FILE__)
end

def fixture(filename)
  File.new("#{fixture_path}/#{filename}")
end