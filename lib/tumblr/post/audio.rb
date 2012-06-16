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
    end
  end
end


