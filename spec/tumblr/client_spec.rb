require "spec_helper"

describe Tumblr::Client do
  before do
    @client = described_class.new
    @domain = described_class.domain
    @oauth = {
      :consumer_key => "consumer-key",
      :consumer_secret => "consumer-secret",
      :token => "auth-token",
      :token_secret => "token-secret"
    }
    stub_request :any, /api\.tumblr\.com\/.*/
  end

  describe "::headers" do
    it "includes the Tumblr client user agent string" do
      described_class.headers["User-Agent"].should match /Tumblr API Client/
    end
  end

  describe "#info" do
    it "gets the info for a particular blog" do
      api_key = @oauth[:consumer_key]
      hostname = "mwunsch.tumblr.com"
      req = @client.info :api_key => api_key, :hostname => hostname
      req.perform.force
      a_request(:get, "#{@domain}/blog/#{hostname}/info").with(:query => {
        "api_key" => api_key
      }).should have_been_made
    end
  end

  describe "#avatar" do
    it "gets the avatar for a particular blog" do
      hostname = "mwunsch.tumblr.com"
      req = @client.avatar :hostname => hostname
      req.perform.force
      a_request(:get, "#{@domain}/blog/#{hostname}/avatar").should have_been_made
    end
  end

  describe "#followers" do
    it "gets the followers for an authorized blog" do
      hostname = "mwunsch.tumblr.com"
      req = @client.followers @oauth.merge(:hostname => hostname)
      req.perform.force
      a_request(:get, "#{@domain}/blog/#{hostname}/followers").with {|request|
        request.headers.has_key? "Authorization"
      }.should have_been_made
    end
  end

  describe "#posts" do
    it "gets the posts for a particular blog" do
      api_key = @oauth[:consumer_key]
      hostname = "mwunsch.tumblr.com"
      req = @client.posts :api_key => api_key, :hostname => hostname
      req.perform.force
      a_request(:get, "#{@domain}/blog/#{hostname}/posts").with(:query => {
        "api_key" => api_key
      }).should have_been_made
    end
  end

  describe "#queue" do
    it "gets the contents of a queue for an authorized blog" do
      hostname = "mwunsch.tumblr.com"
      req = @client.queue @oauth.merge(:hostname => hostname)
      req.perform.force
      a_request(:get, "#{@domain}/blog/#{hostname}/posts/queue").with {|request|
        request.headers.has_key? "Authorization"
      }.should have_been_made
    end
  end

  describe "#draft" do
    it "gets the draft posts for an authorized blog" do
      hostname = "mwunsch.tumblr.com"
      req = @client.draft @oauth.merge(:hostname => hostname)
      req.perform.force
      a_request(:get, "#{@domain}/blog/#{hostname}/posts/draft").with {|request|
        request.headers.has_key? "Authorization"
      }.should have_been_made
    end
  end

  describe "#submission" do
    it "gets the submission posts for an authorized blog" do
      hostname = "mwunsch.tumblr.com"
      req = @client.submission @oauth.merge(:hostname => hostname)
      req.perform.force
      a_request(:get, "#{@domain}/blog/#{hostname}/posts/submission").with {|request|
        request.headers.has_key? "Authorization"
      }.should have_been_made
    end
  end

  describe "#post" do
    it "posts to the authorized blog" do
      hostname = "mwunsch.tumblr.com"
      req = @client.post @oauth.merge(:hostname => hostname, :type => "text", :body => "Hello, world.")
      req.perform.force
      a_request(:post, "#{@domain}/blog/#{hostname}/post").with {|request|
        request.headers.has_key? "Authorization" and !request.body.empty?
      }.should have_been_made
    end
  end

  describe "#edit" do
    it "edits a post of the authorized blog" do
      hostname = "mwunsch.tumblr.com"
      req = @client.edit @oauth.merge(:hostname => hostname, :id => "my-text-post", :body => "Hello, world.")
      req.perform.force
      a_request(:post, "#{@domain}/blog/#{hostname}/post/edit").with {|request|
        request.headers.has_key? "Authorization" and !request.body.empty?
      }.should have_been_made
    end
  end

  describe "#reblog" do
    it "reblogs a post to the authorized blog" do
      hostname = "mwunsch.tumblr.com"
      req = @client.reblog @oauth.merge(:hostname => hostname, :id => "my-text-post", :reblog_key => "rebloggable")
      req.perform.force
      a_request(:post, "#{@domain}/blog/#{hostname}/post/reblog").with {|request|
        request.headers.has_key? "Authorization" and !request.body.empty?
      }.should have_been_made
    end
  end

  describe "#user" do
    it "gets the authorized user's account information" do
      req = @client.user @oauth
      req.perform.force
      a_request(:post, "#{@domain}/user/info").with {|request|
        request.headers.has_key? "Authorization"
      }.should have_been_made
    end
  end

  describe "#dashboard" do
    it "gets the authorized user's dashboard" do
      req = @client.dashboard @oauth
      req.perform.force
      a_request(:get, "#{@domain}/user/dashboard").with {|request|
        request.headers.has_key? "Authorization"
      }.should have_been_made
    end
  end

  describe "#likes" do
    it "gets the authorized user's likes" do
      req = @client.likes @oauth
      req.perform.force
      a_request(:get, "#{@domain}/user/likes").with {|request|
        request.headers.has_key? "Authorization"
      }.should have_been_made
    end
  end

  describe "#following" do
    it "gets the authorized user's list of followed users" do
      req = @client.following @oauth
      req.perform.force
      a_request(:get, "#{@domain}/user/following").with {|request|
        request.headers.has_key? "Authorization"
      }.should have_been_made
    end
  end

  describe "#follow" do
    it "follows a blog" do
      req = @client.follow @oauth.merge(:url => "www.davidslog.com")
      req.perform.force
      a_request(:post, "#{@domain}/user/follow").with {|request|
        request.headers.has_key? "Authorization" and !request.body.empty?
      }.should have_been_made
    end
  end

  describe "#unfollow" do
    it "unfollows a blog" do
      req = @client.unfollow @oauth.merge(:url => "www.davidslog.com")
      req.perform.force
      a_request(:post, "#{@domain}/user/unfollow").with {|request|
        request.headers.has_key? "Authorization" and !request.body.empty?
      }.should have_been_made
    end
  end

  describe "#like" do
    it "likes a post" do
      req = @client.like @oauth.merge(:id => "a-post", :reblog_key => "rebloggable")
      req.perform.force
      a_request(:post, "#{@domain}/user/like").with {|request|
        request.headers.has_key? "Authorization" and !request.body.empty?
      }.should have_been_made
    end
  end

  describe "#unlike" do
    it "unlikes a post" do
      req = @client.unlike @oauth.merge(:id => "a-post", :reblog_key => "rebloggable")
      req.perform.force
      a_request(:post, "#{@domain}/user/unlike").with {|request|
        request.headers.has_key? "Authorization" and !request.body.empty?
      }.should have_been_made
    end
  end

  describe "#tagged" do
    it "gets posts with a tag" do
      api_key = @oauth[:consumer_key]
      req = @client.tagged :api_key => api_key, :tag => "gif"
      req.perform.force
      a_request(:get, "#{@domain}/tagged").with(:query => {
        "api_key" => api_key,
        "tag"     => "gif"
      }).should have_been_made
    end
  end
end
