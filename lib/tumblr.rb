require 'weary'

require 'tumblr/post'
require 'tumblr/reader'
require 'tumblr/writer'
require 'tumblr/authenticator'

class Tumblr
  VERSION = "0.0.1"
  GENERATOR = "The Tumblr Gem v#{VERSION}"
  
  # Parse a post out of a string
  def self.parse(doc)
    document = {}
    if doc =~ /^(\s*---(.*)---\s*)/m
      document[:data] = YAML.load(Regexp.last_match[2].strip)
      document[:body] = doc.sub(Regexp.last_match[1],'')
    else
      document[:data] = {'type' => infer_post_type(doc)}
      document[:body] = doc
    end
    create_post document
  end
  
  def infer_post_type(doc)
    :regular
  end
      
  # Map a post type key to its class
  def self.map(key)
    case key
      when :regular
        Post::Regular
      when :photo
        Post::Photo
      when :quote
        Post::Quote
      when :link
        Post::Link
      when :conversation
        Post::Conversation
      when :video
        Post::Video
      when :audio
        Post::Audio
      else
        raise "#{key} is not an understood Tumblr post type"
    end
  end
  
  private
  
  def self.create_post(document)
    data = document[:data]
    body = document[:body]
    type = data['type'].to_sym
    case type
      when :regular
        post = map(type).new(data['post-id'])
        post.body = body
        post
      else
        raise "How did you get here? #{post} is not a Tumblr post."
    end
  end
end