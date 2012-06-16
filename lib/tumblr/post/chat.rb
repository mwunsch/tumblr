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
    end
  end
end



