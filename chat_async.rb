require "rubygems"
require 'sinatra/async'
require "logger"
require "ruby-debug"
require "erb"
require "json"
require File.dirname(__FILE__) + "/message_broker"


class ChatAsync < Sinatra::Base
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
  
  # /messages.json
  # => all messages since app started
  
  # /messages.json?since=1234
  # => long-running response if there are no messages
  # => return messages immediately if there's any
  
  aget '/messages.json' do
    logger.info "message request since #{params[:since]}"
    
    content_type :json

    # /messages.json?since=12345678
    if params[:since]
      msgs = MessageBroker.messages_since params[:since].to_i
      
      if msgs.size > 0
        body { {:messages => msgs } }.to_json
      else
        EM.add_periodic_timer(1){
          
        }
      end
      
    # /messages.json?from=1234&subscribe=true
    # elsif params[:since] && params[:subscribe]
    #   EM.add_periodic_timer(1) {
    #     
    #   }
      
    # /messages.json
    # simply returns all the messages
    else
      body { {:messages => MessageBroker.messages }.to_json }
    end
  end
  
  apost '/message.json' do
    text = params[:text]
    user_name = request.cookie[:username]
    msg = Message.new(text,user_name)
    MessageBroker.add(msg)
    
    # publish
    @@users.each do |user|
      user.body { {:message => msg }.to_json }
    end
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

Rack::Handler::Thin.run ChatAsync.new,:Port => 3030 do |server|
  server.timeout = 0
end