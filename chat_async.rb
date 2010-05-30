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
  #set :sessions, true
  use Rack::Session::Cookie
    
  configure do
    LOGGER = Logger.new(STDOUT) 
  end

  helpers do
    def logger
      LOGGER
    end
    
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
    text = params[:text]
    user_name = session[:user_name]
    msg = Message.new(text,user_name)
    MessageBroker.add(msg)
    
    {:messages => [msg]}.to_json
  end
  
  aget '/login/:id' do
    id = params[:id]
  end

  get '/' do
    session[:hoge] = "asdfw"
    erb :welcome    
  end
    
  post '/logout' do
    username = session[:username]
    logger.debug("logout called :#{username}")
    MessageBroker.remove_user(username)
    puts "logged out"
  end

end