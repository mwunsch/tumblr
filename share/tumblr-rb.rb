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
    system "gem", "install", "tumblr-rb",
             "--version", "2.0.0",
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
  url "http://rubygems.org/downloads/tumblr-rb-2.0.0.gem"
  homepage "http://rubygems.org/gems/tumblr-rb"
  version "2.0.0"
end
