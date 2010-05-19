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
  
  apost '/login' do
    logger.debug env["async.close"]
    user_name = params[:user_name].to_sym

    if MessageBroker.add_user(user_name)
      logger.info "adding #{user_name} to connections"
      response.set_cookie("username",user_name)
      
      body {
        erb :chat,:locals => { :connections => MessageBroker.users }
      }
    else
      body { "User name is already used!" }
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
        body { {:messages => msgs }.to_json }
      else
        EM.add_periodic_timer(1){
          next_msgs = MessageBroker.messages_since params[:since].to_i
          if next_msgs.size > 0
            body { {:messages => next_msgs}.to_json }
          end
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
    user_name = request.cookies["username"]
    msg = Message.new(text,user_name)
    MessageBroker.add(msg)
    
    body { { :messages => [msg]}.to_json }
    # publish
    # MessageBroker.publish_last_message
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
  
  apost '/logout' do
    username = request.cookies["username"]
    logger.debug("part called :#{username}")
    MessageBroker.remove_user(username)
    body {}
  end

end

Rack::Handler::Thin.run ChatAsync.new,:Port => 3030 do |server|
  server.timeout = 0
end