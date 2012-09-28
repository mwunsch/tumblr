require 'thor'
require 'tumblr'

module Tumblr
  class CommandLineInterface < Thor
    include Thor::Actions

    default_task :pipe

    class_option :credentials, :type => :string,
                               :desc => "The file path where your Tumblr OAuth keys are stored. Defaults to ~/.tumblr."

    check_unknown_options!(:except => [])


    desc "post", "Posts a photo from a url to tumblr"
    option :host, :type => :string,
                  :desc => "The hostname of the blog you want to post to"
    def post(arg)
      if options[:host].nil?
        host = ask("Hostname plz?") if $stdin.tty?
      end
      host ||= options[:host]
      abort "You need a hostname." if host.nil? or host.empty?
      abort "No, dude. No." unless has_credentials?
      client = Tumblr::Client.load host, options[:credentials]
      post =  if arg.respond_to? :read
                Tumblr::Post.load arg.read
              elsif File.file?(file_path = File.expand_path(arg))
                Tumblr::Post.load_from_path file_path
              else
                Tumblr::Post.load arg.to_s
              end
      puts post.serialize
      # response = post.post(client).perform
      # puts response.body
    end

    desc "authorize", "Authenticate and authorize the cli"
    long_desc <<-LONGDESC
      `tumblr authorize` will start up a server to run an app to do the OAuth handshake with tumblr.
    LONGDESC
    option :port, :type => :string,
                  :default => "4567"
    option :host, :type => :string,
                  :default => "0.0.0.0"
    def authorize(*soak)
      require 'tumblr/authentication'
      sinatra_options = {
        :port => options[:port],
        :bind => options[:host],
        :credential_path => options[:credentials]
      }
      Tumblr::Authentication.run!(sinatra_options) do |server|
        `open http://#{options[:host]}:#{options[:port]}/`
      end
      if has_credentials?
        puts "Great success! Your Tumblr OAuth credentials were written to #{credentials.path}"
      else
        abort "Something went wrong in authorization, and credentials were not correctly written to #{credentials.path}"
      end
    end

    desc "version", "Print Tumblr version information"
    def version
      puts Tumblr::VERSION
    end

    desc "pipe", "Pipe post content in from STDIN"
    option :host, :type => :string,
                  :desc => "The hostname of the blog you want to post to"
    def pipe
      if !$stdin.tty?
        post($stdin)
      else
        invoke :help
      end
    end

    private

    def credentials
      require 'tumblr/credentials'
      Tumblr::Credentials.new(options[:credentials])
    end

    def has_credentials?
      !credentials.read.empty?
    end

  end
end