class Tumblr
  class Authenticator < Weary::Base
    
    def initialize(*credentials)
      @defaults = {:email => credentials[0], :password => credentials[1]} unless credentials.blank?
    end
    
    # http://www.tumblr.com/docs/en/api#authenticate
    post :authenticate do |auth|
      auth.url = 'http://www.tumblr.com/api/authenticate'
      auth.requires = [:email, :password]
    end
    
  end
end