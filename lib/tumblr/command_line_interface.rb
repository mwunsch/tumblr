require 'thor'
require 'tumblr'

module Tumblr
  class CommandLineInterface < Thor
    include Thor::Actions

    default_task :pipe

    class_option :credentials, :type => :string,
                               :desc => "The file path where your Tumblr OAuth keys are stored. Defaults to ~/.tumblr."
    class_option :host, :type => :string,
                        :desc => 'The hostname of the blog you want to post to i.e. "YOUR-NAME.tumblr.com"'


    check_unknown_options!(:except => [])


    desc "post", "Posts a photo from a url to tumblr"
    method_option :publish, :type => :boolean,
                            :aliases => "-p"
    method_option :queue, :type => :boolean,
                          :aliases => "-q"
    method_option :draft, :type => :boolean,
                          :aliases => "-d"
    def post(arg)
      check_credentials
      host = get_host
      client = Tumblr::Client.load host, options[:credentials]
      post =  if arg.respond_to? :read
                Tumblr::Post.load arg.read
              elsif File.file?(file_path = File.expand_path(arg))
                Tumblr::Post.load_from_path file_path
              else
                Tumblr::Post.load arg.to_s
              end
      post.publish! if options[:publish]
      post.queue! if options[:queue]
      post.draft! if options[:draft]
      response = post.post(client).perform
      if response.success?
        puts %Q(Post was successfully created! Post ID: #{response.parse["response"]["id"]})
      else
        abort %Q(Tumblr returned an Error #{response.status}: #{response.parse["response"]["errors"].join})
      end
    end

    desc "edit", "Edit a post"
    long_desc "Open up your $EDITOR to edit a published post."
    def edit(id)
      check_credentials
      host = get_host
      client = Tumblr::Client.load host, options[:credentials]
      get_post_response = client.posts(:id => id, :filter => :raw).perform
      post =  if get_post_response.success?
                begin
                  Tumblr::Post.create(get_post_response.parse["response"]["posts"].first)
                rescue
                  abort "#{$!}: #{$@}"
                end
              else
                abort "Something went wrong fetching the post."
              end
      require 'tempfile'
      tmp_file = Tempfile.new("post_#{id}")
      begin
        tmp_file.write(post.serialize)
        tmp_file.rewind
        edited_post = if system "$EDITOR #{tmp_file.path}"
                        Tumblr::Post.load_from_path tmp_file.path
                      else
                        abort "Something went seriously wrong."
                      end
        if edited_post.edit(client).perform.success?
          puts "Post #{id} successfully edited."
        else
          abort "Something went wrong when editing the post."
        end
      rescue
        abort "#{$!}: #{$@}"
      ensure
        tmp_file.close
        tmp_file.unlink
      end
    end

    desc "authorize", "Authenticate and authorize the cli"
    long_desc <<-LONGDESC
      `tumblr authorize` will start up a server to run an app to do the OAuth handshake with tumblr.
    LONGDESC
    option :port, :type => :string,
                  :default => "4567"
    option :bind, :type => :string,
                  :default => "0.0.0.0"
    def authorize(*soak)
      require 'tumblr/authentication'
      sinatra_options = {
        :port => options[:port],
        :bind => options[:bind],
        :credential_path => options[:credentials]
      }
      Tumblr::Authentication.run!(sinatra_options) do |server|
        `open http://#{options[:bind]}:#{options[:port]}/`
      end
      if has_credentials?
        puts "Success! Your Tumblr OAuth credentials were written to #{credentials.path}"
      else
        abort "Something went wrong in authorization, and credentials were not correctly written to #{credentials.path}"
      end
    end

    desc "version", "Print Tumblr version information"
    def version
      puts Tumblr::VERSION
    end

    desc "pipe", "Pipe post content in from STDIN"
    method_option :publish, :type => :boolean,
                            :aliases => "-p"
    method_option :queue, :type => :boolean,
                          :aliases => "-q"
    method_option :draft, :type => :boolean,
                          :aliases => "-d"
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

    def check_credentials
      abort "Unable to find your OAuth keys. Run `tumblr authorize` to authenticate with Tumblr." unless has_credentials?
    end

    def get_host
      host = ask("What is your Tumblr hostname?") if options[:host].nil? and $stdin.tty?
      host ||= options[:host]
      abort "You need to provide a hostname i.e. --host=YOUR-NAME.tumblr.com" if host.nil? or host.empty?
      host
    end

  end
end