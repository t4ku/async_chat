require "rubygems"
require 'sinatra/async'
require "logger"
require "ruby-debug"
require "erb"
require "json"
require File.dirname(__FILE__) + "/message_broker"

class ChatAsync < Sinatra::Base
  register Sinatra::Async
  
  alias :original_call :call!
  
  def call!(env)
    #debugger
    self.original_call(env)    
  end
  
  enable :show_exceptions
  set :public => './public'
  use Rack::Session::Cookie,:secret => "f34d2"
  
  configure do
    LOGGER = Logger.new(STDOUT) 
  end

  helpers do
    def logger
      LOGGER
    end
    
  end
  
  get '/' do
    username = session[:user_name]
    logger.info("username #{session[:user_name]}")
    if username && (MessageBroker.users.keys.include? username.to_sym)
      erb :chat,:locals => { :connections => MessageBroker.users }
    else
      erb :welcome
    end
  end
    
  post '/logout' do
    username = session[:user_name]
    logger.debug("logout called :#{user_name}")
    MessageBroker.remove_user(username)
    session[:user_name] = nil
    puts "logged out"
  end

  post '/login' do
    logger.debug env["async.close"]
    user_name = params[:user_name].to_sym

    if MessageBroker.add_user(user_name)
      logger.info "adding #{user_name} to connections"
      session[:user_name] = user_name
      
      erb :chat,:locals => { :connections => MessageBroker.users }
    else
      "User name is already used!" 
    end 
  end
  
  # /messages.json
  # => all messages since app started
  
  # /messages.json?since=1234
  # => long-running response if there are no messages
  # => return messages immediately if there's any
  
  aget '/messages.json' do
    logger.info "#{session[:user_name]} requested messages"
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
      
    else
      body { {:messages => MessageBroker.messages }.to_json }
    end
  end
  
  post '/message.json' do
    logger.debug "message sent from #{session[:user_name]}"
    
    text = params[:text]
    user_name = session[:user_name]
    msg = Message.new(text,user_name)
    MessageBroker.add(msg)
    
    {:messages => [msg]}.to_json
  end
end