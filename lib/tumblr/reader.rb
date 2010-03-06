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
      like.requires = [:email, :password, 'post-id', 'reblog-key']
    end

    # http://www.tumblr.com/docs/en/api#api_liking    
    post :unlike do |unlike|
      unlike.url = "http://www.tumblr.com/api/unlike"
      unlike.requires = [:email, :password, 'post-id', 'reblog-key']
    end
  
  end
end