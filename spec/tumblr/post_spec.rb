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