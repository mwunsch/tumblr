class Tumblr
  class Writer < Weary::Base
    
    def initialize(*credentials)
      @defaults = {:generator => Tumblr::GENERATOR}
      @defaults.merge!({:email => credentials[0], :password => credentials[1]}) unless credentials.blank?
    end
    
    # http://www.tumblr.com/docs/en/api#api_write
    post :write do |write|
      write.url = 'http://www.tumblr.com/api/write'
      write.requires = [:email, :password, :type]
      write.with = (Post::BASIC_PARAMS | Post::POST_PARAMS)
    end
    
    # http://www.tumblr.com/docs/en/api#editing_posts
    post :edit do |edit|
      edit.url = 'http://www.tumblr.com/api/write'
      edit.requires = [:email, :password, :'post-id']
      edit.with = (Post::BASIC_PARAMS | Post::POST_PARAMS)
    end
    
  end
end