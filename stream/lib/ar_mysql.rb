require "rubygems"
require "sinatra/base"
require "active_record"

ActiveRecord::Base.establish_connection(
  :adapter => 'sqlite3',
  :database => File.expand_path('./../../tascasl/db/development.sqlite3')
)

require File.expand_path('./message')
require File.expand_path('./user')
require File.expand_path('./message_broker')

module Sinatra
  module ArMySql
    def authenticated?(api_key)
      return User.find_by_single_access_token(api_key) ? true : false
    end
  end
  
  helpers ArMySql 
end

