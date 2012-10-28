require "spec_helper"

describe Tumblr::Post do
  before do
    @client = Tumblr::Client.new("mwunsch.tumblr.com")
    @request = @client.posts :api_key => "my-consumer-key"
    stub_request(:get, /api\.tumblr\.com\/.+\/posts.+/).to_return fixture('posts.json')

  end

  describe "::perform" do
    it "creates a set of Post objects given a request" do
      posts = described_class.perform(@request)
      posts.should be_all {|post| post.is_a? described_class }
    end
  end

  describe "::create" do
    it "creates a subclass of Post from a post_response" do
      first_post = @request.perform.parse["response"]["posts"].first
      post = described_class.create(first_post)
      post.should be_kind_of Tumblr::Post::Link
    end
  end

  describe "::load" do
    it "loads a post from a serialized, YAML front-matter format" do
      first_post = @request.perform.parse["response"]["posts"].first
      post = described_class.create(first_post)

      loaded_post = described_class.load(post.serialize)
      loaded_post.serialize.should eql post.serialize
    end
  end

  describe "::load_from_path" do
    # The typical_animated_gif.gif c/o topherchris.com
    it "determines post type based on file" do
      post = described_class.load_from_path "#{fixture_path}/typical_animated_gif.gif"
      post.should be_kind_of Tumblr::Post::Photo
    end

    it "raises an exception when the path is not a file" do
      expect { described_class.load_from_path("#{fixture_path}/foo_bazzy.png") }.to raise_error(ArgumentError)
    end
  end

  describe "::infer_post_type_from_string" do
    it "infers a video post from youtube" do
      type = described_class.infer_post_type_from_string("http://www.youtube.com/watch?v=9bZkp7q19f0")
      type.should eql :video
    end

    it "infers a video post from vimeo" do
      type = described_class.infer_post_type_from_string("https://vimeo.com/39610693")
      type.should eql :video
    end

    it "infers a video post from youtube short url" do
      type = described_class.infer_post_type_from_string("http://youtu.be/9bZkp7q19f0")
      type.should eql :video
    end

    it "infers a link post from a generic url" do
      type = described_class.infer_post_type_from_string("http://mwunsch.tumblr.com")
      type.should eql :link
    end

    it "infers an audio post from a spotify url" do
      type = described_class.infer_post_type_from_string("http://open.spotify.com/track/6tGtBvK6DezcjbtUxXGyxe")
      type.should eql :audio
    end

    it "infers an audio post from a soundcloud url" do
      type = described_class.infer_post_type_from_string("http://soundcloud.com/novasolus/bach-goldberg-variations-1-3")
      type.should eql :audio
    end

    it "infers an audio post from a soundcloud short url" do
      type = described_class.infer_post_type_from_string("http://snd.sc/YbrmBi")
      type.should eql :audio
    end

    it "infers an audio post from a spotify direct link" do
      type = described_class.infer_post_type_from_string("spotify:track:6tGtBvK6DezcjbtUxXGyxe")
      type.should eql :audio
    end

    it "infers a text post from anything else" do
      type = described_class.infer_post_type_from_string("Hi, hows it going?")
      type.should eql :text
    end

  end

  describe "#request_parameters" do
    it "transforms a post into a hash for the request" do
      first_post = @request.perform.parse["response"]["posts"].first
      post = described_class.create(first_post)
      post.request_parameters.keys.should be_all do |key|
        (Tumblr::Client::POST_OPTIONS).map(&:to_s).include? key
      end
    end
  end

  describe "#meta_data" do
    it "excludes post body data from the request parameters" do
      first_post = @request.perform.parse["response"]["posts"].first
      post = described_class.create(first_post)
      post.meta_data.keys.should_not include("description")
    end
  end

  describe "#serialize" do
    it "transforms the post into a string w/ YAML frontmatter" do
      first_post = @request.perform.parse["response"]["posts"].first
      post = described_class.create(first_post)
      post.serialize =~ /^(\s*---(.*?)---\s*)/m
      YAML.load(Regexp.last_match[2]).should eql post.meta_data
    end
  end



end