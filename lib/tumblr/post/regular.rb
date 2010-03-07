class Tumblr
  class Post
    class Regular < Post
      
      def initialize(post_id = nil)
        super post_id
        @type = :regular
      end
      
      parameters :title, :body
      
    end
  end
end