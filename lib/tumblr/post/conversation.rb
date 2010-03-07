class Tumblr
  class Post
    class Conversation < Post
      
      def initialize(post_id = nil)
        super post_id
        @type = :conversation
      end
            
    end
  end
end