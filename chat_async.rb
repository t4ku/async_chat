require "rubygems"
require 'sinatra/async'
require "logger"
require "ruby-debug"
require "erb"
require "json"

Debugger.start

log = Logger.new(STDOUT)

class Message
  @@id = 0
  attr_accessor :id,:text,:posted_at
  
  def initialize(text="hello,world")
    @text = text
    @posted_at = (Time.now.to_f * 1000).to_i
    @id = @@id
    @@id += 1
  end
  
  def to_json(*a)
    {
      'id' =>  self.id,
      'text' => self.text,
      'posted_at' => self.posted_at
    }.to_json(*a)
  end
  
  def self.json_create(o)
    new(*o['data'])
  end
end

class AsyncTest < Sinatra::Base
  register Sinatra::Async
  
  enable :show_exceptions
  set :public => './public'
  set :sessions, true
  
  configure do
    LOGGER = Logger.new(STDOUT) 
  end

  helpers do
    def logger
      LOGGER
    end
  end
  
  @@users = {}
  @@messages = [Message.new]
  
  apost '/login' do
    logger.debug env["async.close"]
    user_name = params[:user_name].to_sym

    if @@users.include? user_name
      body { "User name is already used!" }
    else
      logger.info "adding #{user_name} to connections"
      response.set_cookie("username",user_name)
      @@users[user_name] = nil
      
      body {
        erb :chat,:locals => { :connections => @@users }
      }
    end 
  end
  
  aget '/messages/all.json' do
    content_type :json
    EM.add_timer(10){
      body { {:messages => @@messages}.to_json }
    }
  end
  
  apost '/message' do
  end
  
  aget '/login/:id' do
    id = params[:id]
  end

  aget '/' do
    body {
      logger.debug "#{File.dirname(__FILE__)}"
      erb :welcome
    }
    
  end
  
  aget '/release' do
  end
  
  aget '/timer' do
    i = 0
    EM.add_periodic_timer(4) {
    #  if i > 10
    #    body { "yeah"}
    #  end
    #  i++
      logger.debug "i is #{i}"
    }
  end

  aget '/delay/:n' do |n|
    #EM.add_timer(n.to_i) { body { "delayed for #{n} seconds" } }
  end
  
  apost '/chat/' do |message|
    
  end

  aget '/raise' do
    raise 'boom'
  end
end

Rack::Handler::Thin.run AsyncTest.new,:Port => 3030 do |server|
  server.timeout = 0
end