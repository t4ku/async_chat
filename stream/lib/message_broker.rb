#require File.dirname(__FILE__) + "/ar_mysql"

class UserActivity
  attr_accessor :timestamp,:login
  
  def initialize(login,timestamp=nil)
    @timestamp = timestamp || Time.now.to_f * 100
    @login = login
  end
end

class MessageBroker
  @@users = {}
  
  def self.messages_since(timestamp)
    @@messages.select do |message|
      message.timestamp > timestamp
    end
  end
  
  # def self.publish_last_message
  #   @@users.each { |con|
  #     if con
  #         con.body { {:messages => @@messages.last}.to_json }
  #     end
  #   }
  # end
  
  def self.users
    @@users
  end
  
  def self.add_activity(login)
    
  end    
  
  def self.add(msg)
    @@messages << msg
  end
  
  def self.messages
    @@messages
  end
  
  def self.messages_json
    self.messages
  end
end