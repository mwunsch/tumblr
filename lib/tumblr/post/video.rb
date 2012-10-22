module Tumblr
  class Post
    class Video < Post
      def initialize(post_data = {})
        super(post_data)
        @type = :video
        @embed ||= get_embed_code_from_response
      end

      def caption
        @caption
      end

      def embed
        @embed
      end

      def data
        @data
      end

      def get_embed_code_from_response
        @player.last["embed_code"] if @player and !@player.empty?
      end

      def self.post_body_keys
        [:embed, :caption]
      end
    end
  end
end

