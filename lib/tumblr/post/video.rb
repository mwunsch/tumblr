module Tumblr
  class Post
    class Video < Post
      def initialize(post_data = {})
        super(post_data)
        @type = :video
      end

      def caption
        @caption
      end

      def embed
        @embed
      end

      def data
        @data
      end

      def post_body_keys
        [:embed, :caption]
      end
    end
  end
end

