require 'thor'

module Tumblr
  class CommandLineInterface < Thor

    desc "post", "Posts a photo from a url to tumblr"
    def post(host, url)
      require "tumblr/credentials"
      cred = Tumblr::Credentials.new.read
      invoke :authorize if cred.empty?
      client = Tumblr::Client.load(host)
      photo = Tumblr::Post::Photo.new(:source => url, :caption => "I posted this using the bleeding edge of the new Tumblr Command Line utility for #fashionhack day.")
      response = photo.post(client).perform
      puts response.body
    end

    desc "authorize", "Authenticate and authorize the cli"
    def authorize(*soak)
      require 'tumblr/authentication'
      # {:port => 4567, :bind => "0.0.0.0"}
      Tumblr::Authentication.run!() do |server|
        `open http://0.0.0.0:4567/`
      end
    end

  end
end