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

      def url
        @url
      end

      def description
        @description
      end

      def self.post_body_keys
        [:url, :description]
      end
    end
  end
end


