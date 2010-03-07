# An object that represents a post. From:
# http://www.tumblr.com/docs/en/api#api_write

class Tumblr
  class Post
    
    def self.parameters(*attributes)
      if !attributes.blank?
        @parameters = attributes
        attr_accessor *@parameters
      end
      @parameters
    end
    
    attr_reader :type, :state, :post_id, :format
    attr_accessor :slug, :date, :group, :generator
    
    def initialize(post_id = nil)
      @post_id = post_id if post_id
    end
    
    def private=(bool)
      @private = bool ? true : false
    end
    
    def private?
      @private
    end
    
    def tags(*post_tags)
      @tags = post_tags.join(',') if !post_tags.blank?
      @tags
    end
    
    def state=(published_state)
      allowed_states = [:published, :draft, :submission, :queue]
      if !allowed_states.include?(published_state.to_sym)
        raise "Not a recognized published state. Must be one of #{allowed_states.inspect}"
      end
      @state = published_state.to_sym
    end
    
    def format=(markup)
      markup_format = markup.to_sym
      if markup_format.eql?(:html) || markup_format.eql?(:markdown)
        @format = markup_format
      end
    end
    
    def send_to_twitter(status=false)
      if status
        if status.to_sym.eql?(:no)
          @send_to_twitter = false
        else
          @send_to_twitter = status
        end
      end
      @send_to_twitter
    end
    
    def publish_on(pubdate=nil)
      @publish_on = pubdate if state.eql?(:queue) && pubdate
      @publish_on
    end
    
    # Convert to a hash to be used in post writing/editing
    def to_h
      return @to_h if @to_h
      hash = {}
      basics = [:post_id, :type, :date, :tags, :format, :group, :generator,
                :slug, :state, :send_to_twitter, :publish_on]
      params = basics.select {|opt| respond_to?(opt) && send(opt) }
      # params |= self.class.parameters if !parameters.blank?
      params.each { |key| hash[key.to_s.gsub('_','-')] = send(key) } unless params.empty?
      hash['private'] = 1 if private?
      @to_h = hash
    end
    
  end
end

require 'tumblr/post/regular'
require 'tumblr/post/photo'
require 'tumblr/post/quote'
require 'tumblr/post/link'
require 'tumblr/post/conversation'
require 'tumblr/post/video'
require 'tumblr/post/audio'