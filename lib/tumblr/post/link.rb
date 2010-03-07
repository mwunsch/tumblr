class Tumblr
  class Post
    class Link < Post
      
      def initialize(url, post_id = nil)
        super post_id
        self.url = url
        @type = :link
      end
      
      attr_accessor :url, :name, :description
            
    end
  end
end