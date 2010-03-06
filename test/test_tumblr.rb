require 'helper'

class TestTumblr < Test::Unit::TestCase  
  describe 'Reader' do    
    test 'sets up credentials for authentication' do
      reader = Tumblr::Reader
      assert !reader.new.defaults
      params = {:email => 'test@testermcgee.com', :password => 'dontrevealmysecrets'}
      credentials = reader.new(params[:email],params[:password]).defaults
      assert credentials.has_key? :email
      assert credentials.has_key? :password
      assert_equal params, credentials
    end
    
    test 'handles parameters for reads' do
      reader = Tumblr::Reader
      options = {:start => 5, :num => 10, :foo => 'Bar', :type => 'video'}
      cred = {:email => 'test@testermcgee.com', :password => 'dontrevealmysecrets'}
      assert !reader.new.parameters(options).has_key?(:foo)
      assert_equal cred[:email], reader.new(*cred.values).parameters(options)[:email]
      assert reader.new(*cred.values).parameters(options).has_key?(:password)
    end
    
    test 'convenience method for reads' do
      t = Tumblr::Reader
      assert_respond_to t, :read
      assert_equal :get, t.read('mwunsch').via
      assert_equal 'http://mwunsch.tumblr.com/api/read/', t.read('mwunsch').uri.normalize.to_s
      assert_equal :post, t.read('mwunsch',:post).via
      params = {:email => 'test@testermcgee.com', :password => 'dontrevealmysecrets'}
      assert_equal params.to_params, t.read('mwunsch',:post,params).with
    end
  
    test 'reads posts' do
      reader = Tumblr::Reader
      mwunsch = reader.new.read('mwunsch')
      assert_respond_to mwunsch, :perform
      assert_equal 'http://mwunsch.tumblr.com/api/read/', mwunsch.uri.normalize.to_s
      response = hijack! mwunsch, 'read/mwunsch'
      assert response.success?
      assert_equal :xml, response.format
    end
    
    test 'reads posts with some optional parameters' do
      reader = Tumblr::Reader
      options = {:num => 5, :type => :video}
      posts = reader.new.read 'mwunsch', options
      assert_equal options.to_params, posts.with
      response = hijack! posts, 'read/optional'
      parsed = response.parse["tumblr"]["posts"]
      assert_equal "video", parsed["type"]
      assert_equal 5, parsed['post'].count
    end
    
    test 'attempts to perform an authenticated read' do
      reader = Tumblr::Reader
      auth = reader.new('test@testermcgee.com','dontrevealmysecrets').authenticated_read('mwunsch',{:state => :draft})
      response = hijack! auth, 'read/authenticated'
      assert_equal '420292045', response['tumblr']['posts']['post']['id']
    end
    
    test 'sometimes authentication fails' do
      reader = Tumblr::Reader
      auth = reader.new('test@testermcgee.com','dontrevealmysecrets').authenticated_read('mwunsch')
      response = hijack! auth, 'read/authentication failure'
      assert !response.success?
      assert_equal 403, response.code
    end
    
    test 'can not do an authenticated read without credentials' do
      reader = Tumblr::Reader
      assert_raise RuntimeError do 
        reader.new.authenticated_read('mwunsch')
      end
    end
    
    # need to test these more thoroughly
    test 'has several other authenticated read methods' do
      reader = Tumblr::Reader.new
      assert_respond_to reader, :dashboard
      assert_respond_to reader, :likes
      assert_respond_to reader, :like
      assert_respond_to reader, :unlike
    end
  end
end
