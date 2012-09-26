require 'thor'

module Tumblr
  class CommandLineInterface < Thor

    class_option :credentials, :type => :string,
                               :desc => "The file path where your Tumblr OAuth keys are stored. Defaults to ~/.tumblr."

    desc "post", "Posts a photo from a url to tumblr"
    def post
      abort "No, dude. No." unless has_credentials?
      # client = Tumblr::Client.load(host)
      # photo = Tumblr::Post::Photo.new(:source => url, :caption => "I posted this using the bleeding edge of the new Tumblr Command Line utility for #fashionhack day.")
      # response = photo.post(client).perform
      # puts response.body
    end

    desc "authorize", "Authenticate and authorize the cli"
    def authorize(*soak)
      require 'tumblr/authentication'
      # {:port => 4567, :bind => "0.0.0.0"}
      Tumblr::Authentication.run!() do |server|
        `open http://0.0.0.0:4567/`
      end
    end

    desc "version", "Print Tumblr version information"
    def version
      puts Tumblr::VERSION
    end

    def help
      if !$stdin.tty?
        puts "you put something in the $stdin"
        invoke post
      else
        super
      end
    end

    private

    def credentials
      require 'tumblr/credentials'
      Tumblr::Credentials.new(options[:credentials]).read
    end

    def has_credentials?
      !credentials.empty?
    end

  end
end