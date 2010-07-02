require "rubygems"
require "sinatra/base"
require "active_record"

RAILS_BASE_PATH = File.expand_path "./../tascal"

ActiveRecord::Base.establish_connection(
  :adapter => 'sqlite3',
  :database => RAILS_BASE_PATH + "/db/development.sqlite3"
)

require File.expand_path(RAILS_BASE_PATH + "/app/models/message")
require File.expand_path("lib/user")
require File.expand_path("lib/message_broker")

module Sinatra
  module ArMySql
    def authenticated?(api_key)
      return User.find_by_single_access_token(api_key) ? true : false
    end
    def login_name(api_key)
      user = User.find_by_single_access_token(api_key)
      user ? user.login : nil
    end
  end
  
  helpers ArMySql 
end

