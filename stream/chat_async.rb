require "rubygems"
require 'sinatra/async'
require "logger"
require "ruby-debug"
require "erb"
require "json"

require File.dirname(__FILE__) + "/lib/ar_mysql"

class ChatAsync < Sinatra::Base
  register Sinatra::Async
  helpers Sinatra::ArMySql
  
  enable :show_exceptions
  
  configure do
    LOGGER = Logger.new(STDOUT) 
  end

  helpers do
    def logger
      LOGGER
    end
    
  end
      
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