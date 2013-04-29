module Tumblr
  class Post
    class Quote < Post
      def initialize(post_data = {})
        super(post_data)
        @type = :quote
      end

      def text
        @text
      end

      def source
        @source
      end

      def source_url
        @source_url
      end

      def source_title
        @source_title
      end

      def self.post_body_keys
        [:text]
      end
    end
  end
end

