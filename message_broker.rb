class Message
  @@id = 0
  attr_accessor :id,:text,:timestamp
  
  def initialize(text="hello,world",username="hoge")
    @text = text
    @timestamp = (Time.now.to_f * 1000).to_i
    @username = username
    @id = @@id
    @@id += 1
  end
  
  def to_json(*a)
    {
      'id' =>  self.id,
      'text' => self.text,
      'timestamp' => self.timestamp
    }.to_json(*a)
  end
  
  def self.json_create(o)
    new(*o['data'])
  end
end

class MessageBroker
  @@messages = [Message.new()]
  @@users = {}
  
  def self.messages_since(timestamp)
    @@messages.select do |message|
      message.timestamp > timestamp
    end
  end
  
  def self.publish_last_message
    @@users.each { |con|
      if con
          con.body { {:messages => @@messages.last}.to_json }
      end
    }
  end
  
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