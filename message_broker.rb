class Message
  @@id = 0
  attr_accessor :id,:username,:type,:text,:timestamp
  
  def initialize(text="welcome to",username="Comet chat")
    @text = text
    @timestamp = (Time.now.to_f * 1000).to_i
    @username = username
    @id = @@id
	  @type = "msg"
    @@id += 1
  end
  
  # 配列の引数(*a)をうまく使えば、messagesで複数のJSONを返せると思ったけど
  # { :messages => msg }.to_jsonで用は足せてる
  def to_json(*a)
    {
      'id' =>  self.id,
	  'username' => self.username,
      'text' => self.text,
	  'type' => self.type,
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