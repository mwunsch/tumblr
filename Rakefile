#!/usr/bin/env rake
require "bundler/gem_tasks"

desc "Build the manual"
task :build_man do
  sh "ronn -br5 --organization='Mark Wunsch' --manual='Tumblr Manual' man/*.ronn"
end
 
desc "Show the manual"
task :man => :build_man do
  exec "man man/tumblr.1"
end
