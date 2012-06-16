module Tumblr
  class Post
    class Photo < Post
      def initialize(post_data = {})
        super(post_data)
        @type = :photo
      end

      def caption
        @caption
      end

      def link
        @link
      end

      def source
        @source
      end

      def data
        @data
      end
    end
  end
end
