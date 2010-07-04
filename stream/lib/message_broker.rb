#require File.dirname(__FILE__) + "/ar_mysql"

class UserActivity
  attr_accessor :timestamp,:login
  @@activities = []
  class << self
    def active_users
      users =[]
      current_time = Time.now.to_f * 100
      count_span = 10
      
      @@activities.reject! do |activity|
        activity.timestamp < current_time - (count_span * 100)
      end
      
      @@activities.reverse_each do |activity|
          if !(users.include? activity.login)
            users << activity.login
          end
      end
      
      return users
    end
    
    # def latest_activity_of(username)
    #   user_activities = @@activities.map { |activity| activity if activity.login == username }.compact!
    # 
    #   (user_activities.sort do |x,y|
    #     x.timestamp <=> y.timestamp
    #   end).first
    # end
  end
  
  def initialize(login,timestamp=nil)
    @timestamp = timestamp || Time.now.to_f * 100
    @login = login
    @@activities << self
  end
end

class MessageBroker
  @@messages = []
  
  def self.messages_since(timestamp)
    # @@messages.select do |message|
    #   message.timestamp > timestamp
    # end
    
    Message.find(:all,:conditions=>["updated_at >= ?",Time.at (timestamp / 100)]).sort_by {|r| r.updated_at }
  end
  
  # def self.publish_last_message
  #   @@users.each { |con|
  #     if con
  #         con.body { {:messages => @@messages.last}.to_json }
  #     end
  #   }
  # end
  
  
  def self.add_message(msg)
    @@messages << msg
  end
  
  
  def self.messages_json
    self.messages
  end
end