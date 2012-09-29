require 'spec_helper'
require 'tumblr/credentials'

describe Tumblr::Credentials do

  describe "#path" do
    it "has a default path of ~/.tumblr" do
      credentials = described_class.new
      credentials.path.should eql File.expand_path("~/.tumblr")
    end

    it "can be overriden at initialization" do
      credentials = described_class.new("~/.tumblr_oauth")
      credentials.path.should eql File.expand_path("~/.tumblr_oauth")
    end
  end

  describe "#write" do
    before do
      @tempfile = Tempfile.new("tumblr_credentials")
      @credentials = described_class.new(@tempfile.path)
      @oauth = {
        "consumer_key" => "consumer-key",
        "consumer_secret" => "consumer-secret",
        "token" => "access-token",
        "token_secret" => "token-secret"
      }
    end

    after do
      @tempfile.close
      @tempfile.unlink
    end

    it "writes oauth credentials to the path" do
      @credentials.write @oauth["consumer_key"], @oauth["consumer_secret"], @oauth["token"], @oauth["token_secret"]
      File.read(@tempfile).should eql YAML.dump(@oauth)
    end
  end

  describe "#read" do
    before do
      @oauth = {
        "consumer_key" => "consumer-key",
        "consumer_secret" => "consumer-secret",
        "token" => "access-token",
        "token_secret" => "token-secret"
      }
      @tempfile = Tempfile.open("tumblr_credentials") {|io| YAML.dump(@oauth, io) }
    end

    after do
      @tempfile.close
      @tempfile.unlink
    end

    it "reads credentials out of the path" do
      described_class.new(@tempfile.path).read.should eql @oauth
    end
  end
end