module Tumblr
  class Post
    class Audio < Post
      def initialize(post_data = {})
        super(post_data)
        @type = :audio
      end

      def caption
        @caption
      end

      def external_url
        @external_url
      end

      def data
        @data
      end

      def post_body_keys
        [:external_url, :caption]
      end
    end
  end
end


