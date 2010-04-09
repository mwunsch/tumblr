# An object that represents a post. From:
# http://www.tumblr.com/docs/en/api#api_write
class Tumblr
  class Post
    BASIC_PARAMS = [:date,:tags,:format,:group,:generator,:private,
                    :slug,:state,:'send-to-twitter',:'publish-on',:'reblog-key']
    POST_PARAMS = [:title,:body,:source,:caption,:'click-through-url',
                   :quote,:name,:url,:description,:conversation,
                   :embed,:'externally-hosted-url']
    REBLOG_PARAMS = [:comment, :as]
    
    def self.parameters(*attributes)
      if !attributes.blank?
        @parameters = attributes
        attr_accessor *@parameters
      end
      @parameters
    end
    
    attr_reader :type, :state, :post_id, :format
    attr_accessor :slug, :date, :group, :generator, :reblog_key
    
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
      post_hash = {}
      basics = [:post_id, :type, :date, :tags, :format, :group, :generator,
                :slug, :state, :send_to_twitter, :publish_on, :reblog_key]
      params = basics.select {|opt| respond_to?(opt) && send(opt) }
      params |= self.class.parameters.select {|opt| send(opt) } unless self.class.parameters.blank?
      params.each { |key| post_hash[key.to_s.gsub('_','-').to_sym] = send(key) } unless params.empty?
      post_hash[:private] = 1 if private?
      post_hash
    end
    
    # Publish this post to Tumblr
    def write(email, password)
      Writer.new(email,password).write(to_h)
    end
    
    def edit(email, password)
      Writer.new(email,password).edit(to_h)
    end
    
    def reblog(email, password)
      Writer.new(email,password).reblog(to_h)
    end
    
    def delete(email, password)
      Writer.new(email,password).delete(to_h)
    end
    
    def like(email,password)
      if (post_id && reblog_key)
        Reader.new(email,password).like(:'post-id' => post_id, :'reblog-key' => reblog_key)
      end
    end
    
    def unlike(email,password)
      if (post_id && reblog_key)
        Reader.new(email,password).unlike(:'post-id' => post_id, :'reblog-key' => reblog_key)
      end
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
    
    # Convert post to a YAML representation
    def to_yaml
      post = {}
      post['data'] = post_data
      post['body'] = to_h[post_body].to_s
      YAML.dump(post)
    end
    
    # Convert post to a string for writing to a file
    def to_s
      post_string = YAML.dump(post_data)
      post_string += "---\x0D\x0A"
      post_string += YAML.load(to_yaml)['body']
      post_string
    end
    
    private
    
    def post_data
      data = {}
      to_h.each_pair do |key,value|
        data[key.to_s] = value.to_s
      end
      data.reject! {|key,value| key.eql?(post_body.to_s) }
      data
    end
    
    def post_body
      case type
        when :regular
          :body
        when :photo
          :source
        when :quote
          :quote
        when :link
          :url
        when :conversation
          :conversation
        when :video
          :embed
        when :audio
          :'externally-hosted-url'
        else
          raise "#{type} is not a recognized Tumblr post type."
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