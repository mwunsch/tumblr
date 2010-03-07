class Tumblr
  class Post
    class Audio < Post
      
      def initialize(post_id = nil)
        super post_id
        @type = :audio
      end
            
    end
  end
end