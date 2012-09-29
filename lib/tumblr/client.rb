require "weary"

module Tumblr
  class Client < Weary::Client
    API_VERSION = "v2"

    USER_AGENT = "Tumblr API Client (Ruby)/#{Tumblr::VERSION} (+http://github.com/mwunsch/tumblr)"

    POST_OPTIONS = [
      :state, :tags, :tweet, :date, :format, :slug,
      :title, :body, # Text posts
      :caption, :link, :source, :data, #Photo posts
      :quote, # Quote posts
      :url, :description, # Link posts
      :conversation, # Chat posts
      :external_url, # Audio posts
      :embed, # Video posts
      :answer # Answer posts ??
    ]

    domain "http://api.tumblr.com/#{API_VERSION}"

    user_agent USER_AGENT

    get :info, "/blog/{hostname}/info" do |r|
      r.required :api_key
    end

    get :avatar, "/blog/{hostname}/avatar" do |r|
      r.optional :size
    end

    get :followers, "/blog/{hostname}/followers" do |r|
      r.oauth!
      r.optional :limit, :offset
    end

    get :posts, "/blog/{hostname}/posts" do |r|
      r.required :api_key
      r.optional :type, :id, :tag, :limit, :offset, :reblog_info,
                 :notes_info, :filter
    end

    get :queue, "/blog/{hostname}/posts/queue" do |r|
      r.oauth!
    end

    get :draft, "/blog/{hostname}/posts/draft" do |r|
      r.oauth!
    end

    get :submission, "/blog/{hostname}/posts/submission" do |r|
      r.oauth!
    end

    post :post, "/blog/{hostname}/post" do |r|
      r.oauth!
      r.required :type
      r.optional *POST_OPTIONS
    end

    post :edit, "/blog/{hostname}/post/edit" do |r|
      r.oauth!
      r.required :id
      r.optional *POST_OPTIONS
    end

    post :reblog, "/blog/{hostname}/post/reblog" do |r|
      r.oauth!
      r.required :id, :reblog_key
      r.optional *(POST_OPTIONS | [:comment])
    end

    post :delete, "/blog/{hostname}/post/delete" do |r|
      r.oauth!
      r.required :id
    end

    get :user, "/user/info" do |r|
      r.oauth!
    end

    get :dashboard, "/user/dashboard" do |r|
      r.oauth!
      r.optional :limit, :offset, :type, :since_id, :reblog_info, :notes_info
    end

    get :likes, "/user/likes" do |r|
      r.oauth!
      r.optional :limit, :offset
    end

    get :following, "/user/following" do |r|
      r.oauth!
      r.optional :limit, :offset
    end

    post :follow, "/user/follow" do |r|
      r.oauth!
      r.required :url
    end

    post :unfollow, "/user/unfollow" do |r|
      r.oauth!
      r.required :url
    end

    post :like, "/user/like" do |r|
      r.oauth!
      r.required :id, :reblog_key
    end

    post :unlike, "/user/unlike" do |r|
      r.oauth!
      r.required :id, :reblog_key
    end

    get :tagged, "/tagged" do |r|
      r.required :api_key, :tag
      r.optional :before, :limit, :filter
    end

    def self.load(hostname = nil, path = nil)
      require "tumblr/credentials"
      credentials = Tumblr::Credentials.new(path).read
      self.new(hostname, credentials)
    end

    def initialize(hostname = nil, oauth_params = {})
      @defaults = {}
      @defaults[:hostname] = hostname if hostname
      [:consumer_key, :consumer_secret, :token, :token_secret].each do |param|
        @defaults[param] = value_for_key_as_string_or_symbol(oauth_params, param) if hash_includes_key_as_string_or_symbol?(oauth_params, param)
      end
      @defaults[:api_key] = value_for_key_as_string_or_symbol(oauth_params, :consumer_key)
    end

    private

    def value_for_key_as_string_or_symbol(hash, key)
      hash[key.to_sym] || hash[key.to_s]
    end

    def hash_includes_key_as_string_or_symbol?(hash, key)
      hash.keys.map(&:to_s).include? key.to_s
    end
  end
end
