require "rubygems"
require 'sinatra/async'
require "logger"
require "ruby-debug"
require "erb"
require "json"

RAILS_BASE_PATH=File.expand_path "./../tascal/"
LIB_BASE_PATH=File.expand_path "./lib/"

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
      
  aget '/stream/messages.json' do
    if authenticated?(params[:api_key])
      content_type :json

      # /messages.json?since=12345678
      if params[:since]
        msgs = MessageBroker.messages_since params[:since].to_i
      
        if msgs.size > 0
          body { {:messages => msgs }.to_json }
        else
          EM.add_periodic_timer(1){
            logger.debug "periodic timer for #{params[:api_key]}"
            next_msgs = MessageBroker.messages_since params[:since].to_i
            if next_msgs.size > 0
              body { {:messages => next_msgs}.to_json }
            end
          }
        end
      
      else
        body { {:messages => MessageBroker.messages }.to_json }
      end
    else
      logger.debug "unauthenticated request"
    end
  end
  
  post '/stream/message.json' do
    if authenticated?(params[:api_key])
      
      user = User.find_by_single_access_token(params[:api_key])
      text = params[:text]
      
      logger.debug "message user: #{user.login} text: #{text}"
      
      msg = Message.new(:text=>text,:user => user)
      MessageBroker.add_message(msg)
    
      {:messages => [msg]}.to_json
    else
      logger.debug "unauthenticated request"
    end
  end
end