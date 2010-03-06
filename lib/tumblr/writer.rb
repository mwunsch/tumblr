class Tumblr
  class Writer < Weary::Base
    
    def initialize(*credentials)
      @defaults = {:email => credentials[0], :password => credentials[1]} unless credentials.blank?
    end
    
    # http://www.tumblr.com/docs/en/api#api_write
    post :write do |write|
      write.url = 'http://www.tumblr.com/api/write'
      write.requires = [:email, :password, :type]
      write.with = [:generator, :date, :private, :tags, :format,
                    :group, :slug, :slate, 'send-to-twitter']
    end
    
  end
end