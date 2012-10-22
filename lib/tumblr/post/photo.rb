module Tumblr
  class Post
    class Photo < Post
      def initialize(post_data = {})
        super(post_data)
        @type = :photo
        @source ||= first_photo_url_from_response
      end

      def caption
        @caption
      end

      def link
        @link
      end

      def source
        @source
      end

      def data
        @data
      end

      def first_photo_url_from_response
        @photos.first["original_size"]["url"] if @photos and !@photos.empty?
      end

      def self.post_body_keys
        [:source, :caption]
      end
    end
  end
end
