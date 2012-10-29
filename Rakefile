#!/usr/bin/env rake
require "bundler/gem_tasks"
require 'rspec/core/rake_task'

task :default => :spec

RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = ["--color", "--format=documentation"]
end

desc "Build the manual"
task :build_man do
  sh "ronn -br5 --organization='Mark Wunsch' --manual='Tumblr Manual' man/*.ronn"
end

desc "Show the manual"
task :man => :build_man do
  exec "man man/tumblr.1"
end

desc "Build a homebrew formula"
file "brew" do
  # Thanks to Josh Peek for making brew-gem
  # https://github.com/josh/brew-gem
  require 'tumblr/version'
  version = Tumblr::VERSION
  gem_name = "tumblr-rb"
  template = ERB.new(File.read(__FILE__).split(/^__END__$/, 2)[1].strip)
  filename = File.join File.dirname(__FILE__), "share", "tumblr-rb.rb"
  File.open(filename, "w") {|f| f.puts template.result(binding) }
end


__END__
# This is a generated file. Run `rake brew`
require 'formula'

class RubyGemFormula < Formula
  class NoopDownloadStrategy < AbstractDownloadStrategy
    def fetch; end
    def stage; end
  end

  def download_strategy
    NoopDownloadStrategy
  end

  def install
    # set GEM_HOME and GEM_PATH to make sure we package all the dependent gems
    # together without accidently picking up other gems on the gem path since
    # they might not be there if, say, we change to a different rvm gemset
    ENV['GEM_HOME']="#{prefix}"
    ENV['GEM_PATH']="#{prefix}"
    system "gem", "install", "<%= gem_name %>",
             "--version", "<%= version %>",
             "--no-rdoc", "--no-ri",
             "--install-dir", prefix
    bin.rmtree
    bin.mkpath

    Pathname.glob("#{prefix}/gems/#{name}-#{version}/man/*").select do |file|
      send("man#{$&}").install(file) if file.extname =~ /\d$/
    end

    ruby_libs = Dir.glob("#{prefix}/gems/*/lib")
    Pathname.glob("#{prefix}/gems/#{name}-#{version}/bin/*").each do |file|
      (bin+file.basename).open('w') do |f|
        f << <<-RUBY
#!/usr/bin/env ruby
ENV['GEM_HOME']="#{prefix}"
$:.unshift(#{ruby_libs.map(&:inspect).join(",")})
load "#{file}"
        RUBY
      end
    end
  end
end

class TumblrRb < RubyGemFormula
  url "http://rubygems.org/downloads/<%= gem_name %>-<%= version %>.gem"
  homepage "http://rubygems.org/gems/<%= gem_name %>"
  version "<%= version %>"
end
