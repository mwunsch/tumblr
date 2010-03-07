#TODO: Support file uploads

class Tumblr
  class Post
    class Photo < Post
                  
      def initialize(post_id = nil)
        super post_id
        @type = :photo
      end
      
      parameters :source, :caption, :click_through_url
            
    end
  end
end