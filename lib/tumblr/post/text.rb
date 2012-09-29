module Tumblr
  class Post
    class Text < Post
      def initialize(post_data = {})
        super(post_data)
        @type = :text
      end

      def body
        @body
      end

      def title
        @title
      end
    end
  end
end
