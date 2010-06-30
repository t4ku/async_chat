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
  
  
  it "should authenticate message with api key param" do
    
  end
  
end