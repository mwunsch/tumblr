module Tumblr
  class Post
    class Answer < Post
      def initialize(post_data = {})
        super(post_data)
        @type = :answer
      end

      def answer
        @answer
      end
    end
  end
end



