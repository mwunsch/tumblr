class Tumblr
  class Post
    class Regular < Post
      
      def initialize(post_id = nil)
        super post_id
        @type = :regular
      end
      
      attr_accessor :title, :body
      
    end
  end
end