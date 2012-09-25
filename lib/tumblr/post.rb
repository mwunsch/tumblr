module Tumblr
  # Not a good idea to instantiate this class directly. Instead, use the Tumblr::Post::create method.
  class Post

    autoload :Text, 'tumblr/post/text'
    autoload :Quote, 'tumblr/post/quote'
    autoload :Link, 'tumblr/post/link'
    autoload :Answer, 'tumblr/post/answer'
    autoload :Video, 'tumblr/post/video'
    autoload :Audio, 'tumblr/post/audio'
    autoload :Photo, 'tumblr/post/photo'
    autoload :Chat, 'tumblr/post/chat'

    STATES = [:published, :draft, :queue]

    FIELDS = [
      :blog_name, :id, :post_url, :type, :timestamp, :date, :format,
      :reblog_key, :tags, :bookmarklet, :mobile, :source_url, :source_title,
      :total_posts
    ]

    POST_BODY_SEPARATOR = "\n\n"

    def self.perform(request)
      response = request.perform
      posts = response.parse["response"]["posts"]

      (posts || []).map{|post| self.create(post) }
    end

    def self.create(post_response)
      type = post_response["type"].to_s.capitalize.to_sym
      get_post_type(post_response["type"]).new(post_response)
    end

    def self.get_post_type(type)
      const_get type.to_s.capitalize.to_sym
    end

    def self.post_body_keys
      [:body]
    end

    def self.load(doc)
      doc =~ /^(\s*---(.*?)---\s*)/m
      foo = {}

      meta_data = YAML.load(Regexp.last_match[2].strip)
      doc_body = doc.sub(Regexp.last_match[1],'').strip

      post_type = get_post_type(meta_data["type"] || meta_data[:type])
      post_body_parts = doc_body.split(POST_BODY_SEPARATOR)

      pairs = pair_post_body_types(post_type.post_body_keys,post_body_parts.dup)
      full_post = Hash[pairs].merge(meta_data)

      post_type.new(full_post)
    end

    def self.pair_post_body_types(keys, values)
      values.fill values[keys.length - 1, values.length - 1].join(POST_BODY_SEPARATOR), keys.length - 1, values.length - 1
      keys.map(&:to_s).zip values
    end

    def self.dump(post)
      post.serialize
    end

    def initialize(post_response = {})
      post_response.delete_if {|k,v| !(FIELDS | Tumblr::Client::POST_OPTIONS).map(&:to_s).include? k }
      post_response.each_pair do |k,v|
        instance_variable_set "@#{k}".to_sym, v
      end
    end

    def serialize
      buffer = YAML.dump(meta_data)
      buffer << "---\x0D\x0A"
      buffer << post_body
      buffer
    end

    def id
      @id.to_i unless @id.nil?
    end

    def type
      @type
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

    def markdown?
      @format.to_s == "markdown"
    end

    def slug
      @slug
    end

    def post(client)
      client.post(request_parameters)
    end

    def edit(client)
      raise "Must have an id to edit a post" unless id
      client.edit(request_parameters)
    end

    def delete(client)
      raise "Must have an id to delete a post" unless id
      client.delete(:id => id)
    end

    def request_parameters
      Hash[(Tumblr::Client::POST_OPTIONS | [:id, :type]).map {|key| [key.to_s, send(key)] if respond_to?(key) && send(key) }]
    end

    def meta_data
      request_parameters.reject {|k,v| self.class.post_body_keys.include?(k.to_sym) }
    end

    private

    def post_body
      self.class.post_body_keys.map{|key| self.send(key) }.join("\n\n")
    end

  end
end
