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
require 'contest'
require 'redgreen'
require 'vcr'

begin
  require 'tumblr'
rescue LoadError
  lib_path = File.join(File.dirname(__FILE__), '..', 'lib')
  $LOAD_PATH.unshift lib_path unless $LOAD_PATH.include?(lib_path)
  require 'tumblr'
end

FakeWeb.allow_net_connect = false

VCR.config do |c|
  # the cache_dir is where the cassette yml files will be saved.
  c.cache_dir = File.join('fixtures', 'vcr_cassettes')

  # this record mode will be used for any cassette you create without specifying a record mode.
  c.default_cassette_record_mode = :none
end

def hijack!(request, fixture)
  record_mode = File.exist?(VCR::Cassette.new(fixture).cache_file) ? :none : :unregistered
  VCR.with_cassette(fixture, :record => record_mode) do
    request.perform
  end
end
