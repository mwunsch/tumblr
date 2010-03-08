require 'weary'

require 'tumblr/post'
require 'tumblr/reader'
require 'tumblr/writer'
require 'tumblr/authenticator'

class Tumblr
  VERSION = "0.0.1"
  GENERATOR = "The Tumblr Gem v#{VERSION}"
  
  def initialize(*credentials)
    @credentials = {:email => credentials[0], :password => credentials[1]} unless credentials.blank?
  end
  
  # Convenience method for Reader#read
  def read(username, parameters={})
    reader = !@credentials.blank? ? Reader.new(@credentials[:email],@credentials[:password]) : Reader.new
    reader.read(username, parameters)
  end
  
  # Post a document to Tumblr. If the document has a post-id, it will be edited.
  def post(doc)
    raise 'Requires an e-mail address and password' unless @credentials
    tumblr_post = if doc.is_a?(Tumblr::Post)
      doc.to_h
    elsif doc.respond_to?(:keys)
      doc
    else
      Tumblr.parse(doc).to_h
    end
    writer = Writer.new(@credentials[:email],@credentials[:password])
    tumblr_post.has_key?(:'post-id') ? writer.edit(tumblr_post) : writer.write(tumblr_post)
  end
  
  # Parse a post out of a string
  def self.parse(doc)
    document = {}
    if doc =~ /^(\s*---(.*)---\s*)/m
      document[:data] = YAML.load(Regexp.last_match[2].strip)
      document[:body] = doc.sub(Regexp.last_match[1],'').strip
    else
      document[:data] = {'type' => infer_post_type(doc)}
      document[:body] = doc
    end
    create_post document
  end
  
  # Guess the Type of Post for a given documents
  def self.infer_post_type(doc)
    begin
      url = URI.parse(doc)
      if url.is_a?(URI::HTTP)
        (url.host.include?('youtube.com') || url.host.include?('vimeo.com')) ? :video : :link
      else
        :regular
      end
    rescue URI::InvalidURIError
      :regular
    end
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
    post_data = document[:data]
    type = (post_data['type'] || infer_post_type(document[:body])).to_sym
    post = case type
      when :regular
        create_regular document
      when :photo
        create_photo document
      when :audio
        create_audio document
      when :quote, :link, :conversation, :video
        create_simple type, document
      else
        raise "#{type} is not a recognized Tumblr post type."
    end
    basic_setup post, post_data
  end
  
  def self.basic_setup(post, post_data)
    %w(format state private slug date group generator).each do |basic|
      post.send "#{basic}=".intern, post_data[basic] if post_data[basic]
    end
    %w(tags send-to-twitter publish-on).each do |attribute|
      post.send attribute.gsub('-','_').intern, post_data[attribute] if post_data[attribute]
    end
    post
  end
  
  def self.setup_params(post, data)
    post_params = post.class.parameters.collect {|param| param.to_s.gsub('_','-') }
    post_params.each do |param|
      post.send "#{param.gsub('-','_')}=".intern, data[param] if data[param]
    end
    post
  end
    
  def self.create_regular(doc)
    data = doc[:data]
    post = Tumblr::Post::Regular.new(data['post-id'])
    post.body = doc[:body]
    setup_params post, data
  end
  
  def self.create_photo(doc)
    data = doc[:data]
    post = Tumblr::Post::Photo.new(data['post-id'])
    post.source = doc[:body]
    setup_params post, data
  end
  
  def self.create_audio(doc)
    data = doc[:data]
    post = Tumblr::Post::Audio.new(data['post-id'])
    post.externally_hosted_url = doc[:body]
    setup_params post, data
  end
  
  def self.create_simple(type, doc)
    data = doc[:data]
    post = map(type).new(doc[:body], data['post-id'])
    setup_params post, data
  end  
  
end