class Tumblr
  class Post
    class Photo < Post
      
      def initialize(post_id = nil)
        super post_id
        @type = :photo
      end
      
      attr_accessor :source, :caption, :click_through_url
      
    end
  end
end