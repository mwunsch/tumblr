module Tumblr
  class Post
    class Quote < Post
      def initialize(post_data = {})
        super(post_data)
        @type = :quote
      end

      def quote
        @quote
      end

      def source
        @source
      end
    end
  end
end

