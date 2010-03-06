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
      response = hijack! mwunsch, 'read/mwunsch read'
      assert response.success?
      assert_equal :xml, response.format
    end
  end
end
