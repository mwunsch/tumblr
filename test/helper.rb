begin
  # Try to require the preresolved locked set of gems.
  require File.expand_path('../.bundle/environment', __FILE__)
rescue LoadError
  # Fall back on doing an unlocked resolve at runtime.
  require "rubygems"
  require "bundler"
  Bundler.setup
end

require 'test/unit'
require 'redgreen'

begin
  require 'tumblr'
rescue LoadError
  lib_path = File.join(File.dirname(__FILE__), '..', 'lib')
  $LOAD_PATH.unshift lib_path unless $LOAD_PATH.include?(lib_path)
  require 'tumblr'
end
