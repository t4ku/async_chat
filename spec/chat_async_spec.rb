require File.dirname(__FILE__) + "/spec_helper"
require "sinatra/async"

describe "AsyncChat" do
  include Rack::Test::Methods

  def app
    @app ||= ChatAsync
    @app.set :views,File.dirname(__FILE__) + "/../views"
  end

  it "should respond to /" do
    get '/'
    last_response.should be_ok
  end
  
  it "should redirect to /chat if the user is already logged in" do
    post '/login',{},{'rack.session' => {:user_name => "first_user"}}
    get '/'
    
    # TODO 
    # find out how to detect redirect to "/chat",or mock app
    last_response.should include "Comet chat"
  end
  
  it "should log user in if the username is unique" do
    post '/login',:user_name => "test"
    last_response.should be_ok    
  end
  
  it "should avoid duplicated user names" do
    post '/login',:user_name => "test"
    last_response.body.should include "already used"
  end
  
  it "should not let user login if the username is empty" do
    post '/login'
    last_response.body.should include "already used"
  end
  
  it "should authenticate message with cookie session" do
    post '/message.json',{},{'rack.session' => {:user_name => "abc" }}
    
    
  end
  
  it "should authenticate message with api key param" do
    
  end
  
end