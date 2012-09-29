module Tumblr
  # A Tumblr::Post object can be serialized into a YAML front-matter formatted string,
  # and provides convenient ways to publish, edit, and delete to the API.
  # Don't call #new directly, instead use Post::create to instantiate a subclass.
  class Post

    autoload :Text, 'tumblr/post/text'
    autoload :Quote, 'tumblr/post/quote'
    autoload :Link, 'tumblr/post/link'
    autoload :Answer, 'tumblr/post/answer'
    autoload :Video, 'tumblr/post/video'
    autoload :Audio, 'tumblr/post/audio'
    autoload :Photo, 'tumblr/post/photo'
    autoload :Chat, 'tumblr/post/chat'

    FIELDS = [
      :blog_name, :id, :post_url, :type, :timestamp, :date, :format,
      :reblog_key, :tags, :bookmarklet, :mobile, :source_url, :source_title,
      :total_posts
    ]

    # Some post types have several "body keys", which allow the YAML front-matter
    # serialization to seem a bit more human. This separator separates those keys.
    POST_BODY_SEPARATOR = "\n\n"

    # Given a Request, perform it and transform the response into a list of Post objects.
    def self.perform(request)
      response = request.perform
      posts = response.parse["response"]["posts"]

      (posts || []).map{|post| self.create(post) }
    end

    # Insantiate a subclass of Tumblr::Post, corresponding to the post's type.
    def self.create(post_response)
      type = post_response["type"].to_s.capitalize.to_sym
      get_post_type(post_response["type"]).new(post_response)
    end

    # Get a subclass of Tumblr::Post based on a type token.
    def self.get_post_type(type)
      const_get type.to_s.capitalize.to_sym
    end

    # Transform a yaml front matter formatted String into a subclass of Tumblr::Post
    def self.load(doc)
      create parse(doc)
    end

    # Load a document and transform into a post via file path
    def self.load_from_path(path)
      raise ArgumentError, "Given path: #{path} is not a file" unless File.file? File.expand_path(path)
      post_type = infer_post_type_from_extname File.extname(path)
      if post_type == :text
        load File.read(File.expand_path(path))
      else
        load_from_binary File.new(File.expand_path(path), "rb"), post_type
      end
    end

    def self.load_from_binary(file, post_type = nil)
      file_size_in_mb = file.size.to_f / 2**20
      raise ArgumentError, "File size is greater than 5 MB (Tumblr's limit)" if file_size_in_mb > 5
      post_type ||= infer_post_type_from_extname File.extname(file.path)
      get_post_type(post_type).new "data" => URI.encode(file.read)
    end

    # Transform a yaml front matter formatted String into a set of parameters to create a post.
    def self.parse(doc)
      doc =~ /^(\s*---(.*?)---\s*)/m

      if Regexp.last_match
        meta_data = YAML.load(Regexp.last_match[2].strip)
        doc_body = doc.sub(Regexp.last_match[1],'').strip
      else
        meta_data = {}
        doc_body = doc
      end
      meta_data["type"] ||= infer_post_type_from_string(doc_body)
      meta_data["format"] ||= "markdown"

      post_type = get_post_type(meta_data["type"])
      post_body_parts = doc_body.split(POST_BODY_SEPARATOR)

      pairs = pair_post_body_types(post_type.post_body_keys, post_body_parts.dup)
      Hash[pairs].merge(meta_data)
    end

    # Pair the post body keys for a particular post type with a list of values.
    # If the length list of values is greater than the list of keys, the last key
    # should be paired with the remaining values joined together.
    def self.pair_post_body_types(keys, values)
      values.fill(keys.length - 1) do |i|
        values[keys.length - 1, values.length].join(POST_BODY_SEPARATOR)
      end
      keys.map(&:to_s).zip values
    end

    def self.infer_post_type_from_extname(extname)
      require 'rack'
      mime_type = Rack::Mime.mime_type extname
      case mime_type.split("/").first
      when "image"
        :photo
      when "video"
        :video
      when "audio"
        :audio
      else
        :text
      end
    end

    def self.infer_post_type_from_string(str)
      # TODO: Infer type
      # If doc is a URL, determine type of URL (image/video/audio) otherwise it's text.
      :text
    end

    # A post_body_key determines what parts of the serialization map to certain
    # fields in the post request.
    def self.post_body_keys
      [:body]
    end

    # Serialize a post.
    def self.dump(post)
      post.serialize
    end

    def initialize(post_response = {})
      post_response.delete_if {|k,v| !(FIELDS | Tumblr::Client::POST_OPTIONS).map(&:to_s).include? k.to_s }
      post_response.each_pair do |k,v|
        instance_variable_set "@#{k}".to_sym, v
      end
    end

    # Transform this post into it's YAML front-matter post form.
    def serialize
      buffer = YAML.dump(meta_data)
      buffer << "---\x0D\x0A"
      buffer << post_body
      buffer
    end

    # Given a client, publish this post to tumblr.
    def post(client)
      client.post(request_parameters)
    end

    # Given a client, edit this post.
    def edit(client)
      raise "Must have an id to edit a post" unless id
      client.edit(request_parameters)
    end

    # Given a client, delete this post.
    def delete(client)
      raise "Must have an id to delete a post" unless id
      client.delete(:id => id)
    end

    # Transform this Post into a hash ready to be serialized and posted to the API.
    # This looks for the fields of Tumblr::Client::POST_OPTIONS as methods on the object.
    def request_parameters
      Hash[(Tumblr::Client::POST_OPTIONS | [:id, :type]).map {|key|
        [key.to_s, send(key)] if respond_to?(key) && send(key)
      }]
    end

    # Which parts of this post represent it's meta data (eg. they're not part of the body).
    def meta_data
      request_parameters.reject {|k,v| self.class.post_body_keys.include?(k.to_sym) }
    end

    # Below this line are public methods that are used to transform this post into an API request.

    def id
      @id.to_i unless @id.nil?
    end

    def type
      @type
    end

    def reblog_key
      @reblog_key
    end

    def state
      @state
    end

    def tags
      if @tags.respond_to? :join
        @tags.join(",")
      else
        @tags
      end
    end

    def tweet
      @tweet
    end

    def date
      @date
    end

    def format
      @format
    end

    def slug
      @slug
    end

    # These are handy convenience methods.

    def markdown?
      @format.to_s == "markdown"
    end

    def published?
      @state.to_s == "published"
    end

    def draft?
      @state.to_s == "draft"
    end

    def queued?
      @state.to_s == "queued" or @state.to_s == "queue"
    end

    def private?
      @state.to_s == "private"
    end

    def publish!
      @state = "published"
    end

    def queue!
      @state = "queue"
    end

    def draft!
      @state ="draft"
    end

    private

    def post_body
      self.class.post_body_keys.map{|key| self.send(key) }.join(POST_BODY_SEPARATOR)
    end

  end
end
