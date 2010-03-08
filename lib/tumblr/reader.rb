#TODO: Documentation
class Tumblr
  class Reader < Weary::Base
    
    def initialize(*credentials)
      @defaults = {:email => credentials[0], :password => credentials[1]} unless credentials.blank?
    end
    
    # http://www.tumblr.com/docs/en/api#api_read
    def read(username, params={})
      self.class.read username, :get, parameters(params)
    end
    
    # http://www.tumblr.com/docs/en/api#authenticated_read
    def authenticated_read(username, params={})
      raise 'Needs requirements badly' unless (params.include?(:email) && params.include?(:password)) || defaults
      self.class.read username, :post, parameters(params)
    end
    
    # Setup parameters for Reads
    def parameters(params)
      allowed = [:start,:num,:type,:id,:filter,:tagged,:search,:state,:email,:password]
      params.merge! defaults if defaults
      params.reject {|key,value| !allowed.include? key }
    end
    
    # Get the Posts as Post objects from a Read response.
    # Pass an additional type parameter to only get Posts of a certain type.
    def self.get_posts(response, type = nil)
      tumblr_post = response['tumblr']['posts']['post']
      posts = tumblr_post.respond_to?(:each_pair) ? [tumblr_post] : tumblr_post
      posts.collect! { |post| build_post(post) }
      return posts.select {|post| post.is_a?(Tumblr.map(type)) } if type
      posts
    end
    
    # Build a Post object from Reader's Post XML
    def self.build_post(post)
      tumblr_post = setup_post(post)
      tumblr_post.date = post['date_gmt']
      tumblr_post.format = post['format'].to_sym if post['format']
      tumblr_post.slug = post['slug']
      tumblr_post.tags post['tag'] if post['tag']
      tumblr_post
    end
    
    # Helper method to facilitate standard GET Read and Authenticated Read
    def self.read(username, via = :get, params = {})
      Weary.request("http://#{username}.tumblr.com/api/read/", via) do |req|
        req.with = params unless params.blank?
      end
    end
    
    # http://www.tumblr.com/docs/en/api#api_dashboard
    post :dashboard do |dashboard|
      dashboard.url = "http://www.tumblr.com/api/dashboard"
      dashboard.requires = [:email,:password]
      dashboard.with = [:start,:num,:type,:filter,:likes]
    end
    
    # http://www.tumblr.com/docs/en/api#api_likes
    post :likes do |likes|
      likes.url = "http://www.tumblr.com/api/likes"
      likes.requires = [:email, :password]
      likes.with = [:start, :num, :filter]
    end
    
    # http://www.tumblr.com/docs/en/api#api_liking
    post :like do |like|
      like.url = "http://www.tumblr.com/api/like"
      like.requires = [:email, :password, :'post-id', :'reblog-key']
    end

    # http://www.tumblr.com/docs/en/api#api_liking    
    post :unlike do |unlike|
      unlike.url = "http://www.tumblr.com/api/unlike"
      unlike.requires = [:email, :password, :'post-id', :'reblog-key']
    end
    
    private
    
    def self.setup_post(post)
      post_type = post['type'].to_sym
      case post_type
        when :regular
          build_regular(post)
        when :photo
          build_photo(post)
        when :quote
          build_quote(post)
        when :link
          build_link(post)
        when :conversation
          build_conversation(post)
        when :video
          build_video(post)
        when :audio
          build_audio(post)
        else
          raise "#{post_type} is not a recognized Tumblr post type."
      end
    end
    
    def self.build_regular(post)
      post_id = post['id']
      regular = Tumblr::Post::Regular.new(post_id)
      regular.body = post['regular_body']
      regular.title = post['regular_title'] 
      regular
    end
    
    def self.build_photo(post)
      post_id = post['id']
      photo = Tumblr::Post::Photo.new(post_id)
      photo.source = post['photo_url'].first
      photo.caption = post['photo_caption']
      photo.click_through_url = post['photo_link_url']
      photo
    end
    
    def self.build_quote(post)
      post_id = post['id']
      quote = Tumblr::Post::Quote.new(post['quote_text'], post_id)
      quote.source = post['quote_source']
      quote
    end
    
    def self.build_link(post)
      post_id = post['id']
      link = Tumblr::Post::Link.new(post['link_url'], post_id)
      link.name = post['link_text']
      link.description = post['link_description']
      link
    end
    
    def self.build_conversation(post)
      post_id = post['id']
      chat = Tumblr::Post::Conversation.new(post['conversation_text'], post_id)
      chat.title = post['conversation_title']
      chat
    end
    
    def self.build_video(post)
      post_id = post['id']
      video = Tumblr::Post::Video.new(post['video_player'], post_id)
      video.caption = post['video_caption']
      video
    end
    
    def self.build_audio(post)
      post_id = post['id']
      audio = Tumblr::Post::Audio.new(post_id)
      audio.caption = post['audio_caption']
      audio 
    end
  
  end
end