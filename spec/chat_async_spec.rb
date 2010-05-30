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
  
  
  
end