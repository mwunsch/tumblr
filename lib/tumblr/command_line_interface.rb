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


    desc "pipe", "Pipe post content in from STDIN"
    method_option :publish, :type => :boolean,
                            :aliases => "-p",
                            :desc => "Publish this post"
    method_option :queue, :type => :boolean,
                          :aliases => "-q",
                          :desc => "Add this post to the queue"
    method_option :draft, :type => :boolean,
                          :aliases => "-d",
                          :desc => "Save this post as a draft"
    long_desc <<-LONGDESC
      Publish a post to tumblr from STDIN for HOST.
      It is assumed that STDIN contains a document formatted according to `tumblr(5)`.
      If STDIN contains a URL, it will create a post using the same rules as `tumblr post`.

      Writes the serialized post to STDOUT.
    LONGDESC
    def pipe
      if !$stdin.tty?
        puts post($stdin).serialize
      else
        invoke :help
      end
    end

    desc "post <POST> | <FILE> | <URL>", "Posts to tumblr"
    method_option :publish, :type => :boolean,
                            :aliases => "-p",
                            :desc => "Publish this post"
    method_option :queue, :type => :boolean,
                          :aliases => "-q",
                          :desc => "Add this post to the queue"
    method_option :draft, :type => :boolean,
                          :aliases => "-d",
                          :desc => "Save this post as a draft"
    long_desc <<-LONGDESC
      Post a POST to Tumblr for HOST. If a FILE path is given, the file will be read and posted to Tumblr.
      It is assumed the post follows the `tumblr(5)` format.

      If the FILE is an audio, image, or video file, it will create the respective post type on tumblr.

      If a URL is given, a link post will be created.
      If URL is a YouTube or Vimeo link, it will create a video post.
      If URL is a SoundCloud or Spotify link, an audio post will be published.
    LONGDESC
    def post(arg)
      client = get_client
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
      tumblr_error(response) unless response.success?
      ui_success %Q(Post was successfully created! Post ID: #{response.parse["response"]["id"]}) if $stdin.tty?
      post
    end

    desc "edit POST_ID", "Edit a post"
    long_desc "Open up your $EDITOR to edit a published post."
    long_desc <<-LONGDESC
      Get a post from Tumblr and edit it.

      Behaves similar to `git commit`, in that it will open up your editor in the foreground.
      Look for a $TUMBLREDITOR environment variable, and if that's not found, will use $EDITOR.
    LONGDESC
    def edit(id)
      client = get_client
      response = client.posts(:id => id, :filter => :raw).perform
      tumblr_error(response) unless response.success?
      post = Tumblr::Post.create(response.parse["response"]["posts"].first)
      require 'tempfile'
      tmp_file = Tempfile.new("post_#{id}")
      tmp_file.write(post.serialize)
      tmp_file.rewind
      ui_abort "Something went wrong editing the post." unless system "#{editor} #{tmp_file.path}"
      edited_post = Tumblr::Post.load_from_path tmp_file.path
      edited_response = edited_post.edit(client).perform
      tumblr_error(edited_response) unless edited_response.success?
      ui_success "Post #{id} successfully edited."
    ensure
      if tmp_file
        tmp_file.close
        tmp_file.unlink
      end
    end

    desc "fetch POST_ID", "Fetch a post and write out its serialized form."
    def fetch(id)
      client = get_client
      response = client.posts(:id => id, :filter => :raw).perform
      tumblr_error(response) unless response.success?
      post = Tumblr::Post.create(response.parse["response"]["posts"].first)
      puts post.serialize
      post
    end

    desc "delete POST_ID", "Delete a post"
    def delete(id)
      client = get_client
      response = client.delete(:id => id).perform
      tumblr_error(response) unless response.success?
      ui_success "Post #{id} successfully deleted."
    end

    desc "authorize", "Authenticate and authorize the cli to post on your behalf"
    option :port, :type => :string,
                  :default => "4567",
                  :desc => "Use PORT"
    option :bind, :type => :string,
                  :default => "0.0.0.0",
                  :desc => "listen on BIND"
    long_desc <<-LONGDESC
      `tumblr authorize` will start up a server (listening on BIND and PORT) running
      a small app to do the OAuth handshake with tumblr.

      The app will open in the default browser, allowing you to authenticate to Tumblr
      and authorize `tumblr` to do actions on your behalf. You will need to register
      an application and enter the consumer key and consumer secret. The application will
      write the OAuth keys to your CREDENTIALS file.

      After authorization, you will be prompted to return to your terminal and shut down
      the server (using CTRL-C).
    LONGDESC
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
        ui_success "Success! Your Tumblr OAuth credentials were written to #{credentials.path}"
      else
        ui_abort "Something went wrong in authorization, and credentials were not correctly written to #{credentials.path}"
      end
    end

    desc "version", "Print Tumblr version information"
    def version
      puts Tumblr::VERSION
    end

    private

    def credentials
      require 'tumblr/credentials'
      Tumblr::Credentials.new(options[:credentials] || ENV["TUMBLRCRED"])
    end

    def editor
      ENV["TUMBLREDITOR"] || ENV["EDITOR"]
    end

    def has_credentials?
      !credentials.read.empty?
    end

    def check_credentials
      ui_abort "Unable to find your OAuth keys. Run `tumblr authorize` to authenticate with Tumblr." unless has_credentials?
    end

    def get_host
      return ENV["TUMBLRHOST"] if ENV["TUMBLRHOST"]
      host = ask("What is your Tumblr hostname?") if options[:host].nil? and $stdin.tty?
      host ||= options[:host]
      ui_abort "You need to provide a hostname i.e. --host=YOUR-NAME.tumblr.com" if host.nil? or host.empty?
      host
    end

    def get_client
      check_credentials
      host = get_host
      Tumblr::Client.load host, options[:credentials]
    end

    def tumblr_error(response)
      parsed_response = response.parse
      msg = parsed_response["response"].empty? ? response.parse["meta"]["msg"] : parsed_response["response"]["errors"]
      ui_abort %Q(Tumblr returned a #{response.status} Error: #{msg})
    end

    def ui_abort(msg, exit_status = 1)
      ui_puts msg, :red
      exit exit_status
    end

    def ui_success(msg)
      ui_puts msg, :green
    end

    def ui_puts(msg, color = nil)
      say msg, $stdout.tty? ? color : nil
    end

  end
end