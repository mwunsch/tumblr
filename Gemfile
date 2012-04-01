source 'http://rubygems.org'

gemspec

gem "rake", "~> 0.9.2"
gem "sinatra", "~> 1.3.2"
gem "weary", :git => "git://github.com/mwunsch/weary.git"

group :test do
  gem "rspec", "~> 2.9.0"
  gem "webmock", "~> 1.8.5"
  gem "rack-test", "~> 0.6.1"
end

platforms :jruby do
  gem "jruby-openssl"
end
