#TODO: Support file uploading

class Tumblr
  class Post
    class Video < Post
      
      def initialize(video, post_id = nil)
        super post_id
        self.embed = video
        @type = :video
      end
      
      parameters :caption, :embed
            
    end
  end
end