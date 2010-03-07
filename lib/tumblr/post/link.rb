class Tumblr
  class Post
    class Link < Post
      
      def initialize(post_id = nil)
        super post_id
        @type = :link
      end
            
    end
  end
end