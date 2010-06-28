#require File.dirname(__FILE__) + "/ar_mysql"

class MessageBroker
  @@messages = [Message.new()]
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
  
  def self.add_user(username)
    if @@users.include? username
      false
    else
      @@users[username.to_sym] = nil
      true
    end
  end
  
  def self.remove_user(username)
    if @@users.include? username
      @@users.delete_if {|user,con| user == username.to_sym }
    end
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