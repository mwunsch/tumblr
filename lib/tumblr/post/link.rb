class Tumblr
  class Post
    class Link < Post
      
      def initialize(url, post_id = nil)
        super post_id
        url = url.to_a.map
        self.url = url.shift.strip
        self.description = url.join
        @type = :link
      end
      
      parameters :url, :name, :description
            
    end
  end
end