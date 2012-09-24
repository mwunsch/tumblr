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

    def self.perform(request)
      response = request.perform
      posts = response.parse["response"]["posts"]

      (posts || []).map{|post| self.create(post) }
    end

    def self.create(post_response)
      type = post_response["type"].to_s.capitalize.to_sym
      const_get(type).new(post_response)
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
      @tags.join(",") if @tags.respond_to? :join
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
      request_parameters.reject {|k,v| post_body_keys.include?(k.to_sym) }
    end

    def post_body_keys
      [:body]
    end

    private

    def post_body
      post_body_keys.map{|key| self.send(key) }.join("\n\n")
    end

  end
end
