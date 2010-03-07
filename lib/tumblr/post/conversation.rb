class Tumblr
  class Post
    class Conversation < Post
      
      def initialize(chat, post_id = nil)
        super post_id
        self.conversation = chat
        @type = :conversation
      end
      
      attr_accessor :conversation, :title
            
    end
  end
end