module Tumblr
  class Post

    TYPES = [
      :text, :quote, :link, :answer, :video, :audio, :photo, :chat
    ]

    STATES = [:published, :draft, :queue]

    FIELDS = [
      :blog_name, :id, :post_url, :type, :timestamp, :date, :format,
      :reblog_key, :tags, :bookmarklet, :mobile, :source_url, :source_title,
      :total_posts
    ]

    def initialize(post_response = {})
      post_response.delete_if {|k,v| !(FIELDS | Tumblr::Client::POST_OPTIONS).include? k }
      post_response.each_pair do |k,v|
        instance_variable_set "@#{k}".to_sym, v
      end
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

    def markdown
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

    def client(hostname, oauth_keys = {})
      Tumblr::Client.new(hostname, oauth_keys)
    end

    def request_parameters
      Hash[(Tumblr::Client::POST_OPTIONS | [:id, :type]).map {|key| [key, send(key)] if respond_to?(key) && send(key) }]
    end

    autoload :Text, 'tumblr/post/text'
    autoload :Quote, 'tumblr/post/quote'
    autoload :Link, 'tumblr/post/link'
    autoload :Answer, 'tumblr/post/answer'
    autoload :Video, 'tumblr/post/video'
    autoload :Audio, 'tumblr/post/photo'
    autoload :Chat, 'tumblr/post/chat'

  end
end
