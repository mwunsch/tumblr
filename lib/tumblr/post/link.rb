module Tumblr
  class Post
    class Link < Post
      def initialize(post_data = {})
        super(post_data)
        @type = :link
      end

      def title
        @title
      end

      def title
        @url
      end

      def description
        @description
      end
    end
  end
end


