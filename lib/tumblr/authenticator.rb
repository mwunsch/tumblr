class Tumblr
  class Authenticator < Weary::Base
    
    headers({"User-Agent" => Tumblr::USER_AGENT})
    
    def initialize(*credentials)
      @defaults = {:email => credentials[0], :password => credentials[1]} unless credentials.blank?
    end
    
    # http://www.tumblr.com/docs/en/api#authenticate
    post :authenticate do |auth|
      auth.url = 'http://www.tumblr.com/api/authenticate'
      auth.requires = [:email, :password]
      auth.with = [:'include-theme']
    end
    
  end
end