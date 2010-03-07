class Tumblr
  class Post
    class Quote < Post
      
      def initialize(post_id = nil)
        super post_id
        @type = :quote
      end
            
    end
  end
end