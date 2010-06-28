require File.dirname(__FILE__) + "/../lib/message_broker"

require "rubygems"
require "spec"
require "json"

describe  Message do
  it "should set all the properties at creation" do
    message = Message.new()
    message.text.should == "welcome to"
    message.id.should be_kind_of Integer
    message.type.should == "msg"
  end
  
  it "should increment user id" do
    msg_first = Message.new()
    msg_second = Message.new()
    msg_first.id.should < msg_second.id
  end
  
  it "should return json representations" do
    message = Message.new()
  end
end

describe MessageBroker do
  it "should retain users" do
    MessageBroker.add_user(:first)
    MessageBroker.add_user(:second)
    MessageBroker.users.keys.include? :first
    MessageBroker.users.keys.include? :second
    MessageBroker.users.keys.size.should == 2
  end
  
  it "should return all the messages since the specified time" do
    start_time = Time.now.to_i
    MessageBroker.add_user(:msg_sender)
    msg = Message.new("first message",:msg_sender)
    MessageBroker.add msg
    MessageBroker.messages_since(start_time).last.text.should == "first message"
  end
end