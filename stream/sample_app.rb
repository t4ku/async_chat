require "rubygems"
require "sinatra"
require "logger"

logger = Logger.new(STDOUT)

# /messages.json
# => all messages since app started
# /messages.json?from=1234
# => all messages from specified time

get '/messages.json' do
  logger.debug params
end