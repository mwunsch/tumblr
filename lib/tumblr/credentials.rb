require "yaml"

module Tumblr
  class Credentials
    FILE_NAME = ".tumblr"

    attr_reader :path

    def initialize(path = nil)
      @path = path || File.join(File.expand_path("~"), FILE_NAME)
    end

    def write(consumer_key, consumer_secret, token, token_secret)
      File.open(path, "w") do |io|
        YAML.dump({
          "consumer_key" => consumer_key,
          "consumer_secret" => consumer_secret,
          "token" => token,
          "token_secret" => token_secret
        }, io)
      end
    end

    def read
      YAML.load_file path
    rescue Errno::ENOENT
      {}
    end

  end
end
