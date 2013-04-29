module Tumblr
  class Post
    class Quote < Post
      def initialize(post_data = {})
        super(post_data)
        @type = :quote
        @quote ||= @text
      end

      def quote
        @quote
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
        [:quote]
      end
    end
  end
end

