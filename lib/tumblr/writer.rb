class Tumblr
  class Writer < Weary::Base
    
    def initialize(*credentials)
      @defaults = {:generator => Tumblr::GENERATOR}
      @defaults.merge!({:email => credentials[0], :password => credentials[1]}) unless credentials.blank?
    end
    
    # http://www.tumblr.com/docs/en/api#api_write
    post :write do |write|
      write.url = 'http://www.tumblr.com/api/write'
      write.with = (Post::BASIC_PARAMS | Post::POST_PARAMS)
      write.requires = [:email, :password, :type]
    end
    
  end
end