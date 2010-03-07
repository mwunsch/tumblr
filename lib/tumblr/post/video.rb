class Tumblr
  class Post
    class Video < Post
      
      def initialize(post_id = nil)
        super post_id
        @type = :video
      end
            
    end
  end
end