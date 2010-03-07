class Tumblr
  class Post
    class Quote < Post
      
      def initialize(quotation, post_id = nil)
        super post_id
        self.quote = quotation
        @type = :quote
      end
      
      attr_accessor :quote, :source
      
            
    end
  end
end