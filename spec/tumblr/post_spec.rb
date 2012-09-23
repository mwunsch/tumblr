require "spec_helper"

describe Tumblr::Post do
  before do
    @client = Tumblr::Client.new("mwunsch.tumblr.com")
    @request = @client.posts :api_key => "my-consumer-key"
    stub_request(:get, /api\.tumblr\.com\/.+\/posts.+/).to_return fixture('posts.json')

  end

  describe "::create" do
    it "creates a set of Post objects given a request" do
      posts = described_class.create(@request)
      posts.should be_all {|post| post.is_a? described_class }
    end

  end



end