#TODO: Support File uploading

class Tumblr
  class Post
    class Audio < Post
      
      def initialize(post_id = nil)
        super post_id
        @type = :audio
      end
      
      attr_accessor :externally_hosted_url, :caption
            
    end
  end
end