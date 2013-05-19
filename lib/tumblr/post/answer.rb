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

      def question
        @question
      end

      def self.post_body_keys
        [:question, :answer]
      end
    end
  end
end

