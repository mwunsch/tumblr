# An object that represents a post. From:
# http://www.tumblr.com/docs/en/api#api_write
class Tumblr
  class Post
    BASIC_PARAMS = [:date,:tags,:format,:group,:generator,:private,
                    :slug,:state,:'send-to-twitter',:'publish-on']
    POST_PARAMS = [:title,:body,:source,:caption,:'click-through-url',
                   :quote,:name,:url,:description,:conversation,
                   :embed,:'externally-hosted-url']
    
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
      post_hash = {}
      basics = [:post_id, :type, :date, :tags, :format, :group, :generator,
                :slug, :state, :send_to_twitter, :publish_on]
      params = basics.select {|opt| respond_to?(opt) && send(opt) }
      params |= self.class.parameters.select {|opt| send(opt) } unless self.class.parameters.blank?
      params.each { |key| post_hash[key.to_s.gsub('_','-').to_sym] = send(key) } unless params.empty?
      post_hash[:private] = 1 if private?
      @to_h = post_hash
    end
    
    # Publish this post to Tumblr
    def write(email, password)
      Writer.new(email,password).write(to_h)
    end
    
    def edit(email, password)
      Writer.new(email,password).edit(to_h)
    end
    
    def delete(email, password)
      Writer.new(email,password).delete(to_h)
    end
    
    # Write to Tumblr and set state to Publish
    def publish_now(email, password)
      self.state = :published
      return edit(email,password) if post_id
      write(email,password)
    end
    
    # Save as a draft
    def save_as_draft(email, password)
      self.state = :draft
      return edit(email,password) if post_id
      write(email,password)
    end
    
    # Adds to Queue. Pass an additional date to publish at a specific date.
    def add_to_queue(email, password, pubdate = nil)
      self.state = :queue
      self.publish_on(pubdate) if pubdate
      return edit(email,password) if post_id
      write(email,password)
    end
    
    def self.map(key)
      case key
        when :regular
          Post::Regular
        when :photo
          Post::Photo
        when :quote
          Post::Quote
        when :link
          Post::Link
        when :conversation
          Post::Conversation
        when :video
          Post::Video
        when :audio
          Post::Audio
        else
          raise "#{key} is not an understood Tumblr post type"
      end
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