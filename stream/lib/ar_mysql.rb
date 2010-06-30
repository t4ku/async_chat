require "rubygems"
require "sinatra/base"
require "active_record"

LIB_BASE_PATH="/Users/ookawataku/Documents/github/ruby/async_chat/stream/lib/"
RAILS_BASE_PATH = "/Users/ookawataku/Documents/github/ruby/async_chat/tascal/"


ActiveRecord::Base.establish_connection(
  :adapter => 'sqlite3',
  :database => File.expand_path(RAILS_BASE_PATH + 'db/development.sqlite3')
)

require File.expand_path(RAILS_BASE_PATH + "app/models/message")
require File.expand_path(LIB_BASE_PATH + 'user')
require File.expand_path(LIB_BASE_PATH + 'message_broker')

module Sinatra
  module ArMySql
    def authenticated?(api_key)
      return User.find_by_single_access_token(api_key) ? true : false
    end
  end
  
  helpers ArMySql 
end

