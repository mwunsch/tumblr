module Tumblr
  class Post
    class Chat < Post
      def initialize(post_data = {})
        super(post_data)
        @type = :chat
      end

      def title
        @title
      end

      def conversation
        @conversation
      end

      def self.post_body_keys
        [:conversation]
      end
    end
  end
end



