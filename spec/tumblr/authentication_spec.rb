require "spec_helper"

describe Tumblr::Authentication do
  require "rack/test"
  include Rack::Test::Methods

  before do
    stub_request :any, /www\.tumblr.com\/oauth\/.*/
    @tempfile = Tempfile.new("tumblr_credentials")
    described_class.set :credential_path, @tempfile.path
  end

  after do
    @tempfile.close
    @tempfile.unlink
  end

  def app
    described_class
  end

  describe "/" do
    it "returns a 400 when no key or secret is given" do
      get "/"
      last_response.status.should eql 400
    end

    it "redirects to tumblr for user authorization" do
      get "/", :key => "consumer-key", :secret => "consumer-secret"
      last_response.status.should eql 302
    end

    it "redirects to tumblr's authorize endpoint" do
      get "/", :key => "consumer-key", :secret => "consumer-secret"
      last_response.location.should match /oauth\/authorize.*/
    end
  end

  describe "/auth" do
    it "returns a 401 when no params are passed (meaning the user denied)" do
      get "/auth"
      last_response.status.should eql 401
    end

    it "posts to tumblr to exchange tokens" do
      get "/auth", :oauth_token => "token", :oauth_verifier => "verifier"
      a_request(:post, /oauth\/access_token/).should have_been_made
    end

    it "writes credentials to the correct path" do
      get "/auth", :oauth_token => "token", :oauth_verifier => "verifier"
      YAML.load(@tempfile.read).should have_key "consumer_key"
    end

  end

end