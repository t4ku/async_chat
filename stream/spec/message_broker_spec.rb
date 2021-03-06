require "spec/spec_helper"

describe MessageBroker do
  before(:all) do
    @valid_user = User.create!(:email => "spec_user_001@example.com",
                               :login => "spec_user_001",
                               :single_access_token => "ZUVIMYCN_duM1UiX5A8S",
                               :password_salt => "ZUVIMYCN_duM1UiX5A8S",
                               :persistence_token => "b314b4447069448409c67e7a5781ba6222c14f5f00c609bb859c76df123078506924eb5f347afd2eb159529116ae99357796cb7a30b2bf9b382e9af48bae8020",
                               :crypted_password => "713ca29c00608ad4426e2b0c5e586740c608ab1230faac5ce734e64906c1329a1ed86e0e1a7e052a1bfa3fd0d8191e79a4fbdad758a0626aae840a4dab95dfdd",
                               :perishable_token => "A95QNR3SmNN7rhYHOSLQ")
    @valid_message = Message.create!(:text => "dummy text",:user => @valid_user)
  end
  
  it "should add message with single access token" do
    #MessageBroker.add_message
    MessageBroker.add_message(@valid_message).should be_true
  end
    
  it "should return messages since specified time" do
    messages = MessageBroker.messages_since (((Time.now.to_i) - 1) *100)
    messages.length.should == 1
  end
  
  after(:all) do
    @valid_user.destroy if @valid_user
    @valid_message.destroy if @valid_message
  end
end

describe UserActivity do 
  
  before(:all) do
    @valid_user = User.create!(:email => "spec_user_001@example.com",
                               :login => "spec_user_001",
                               :single_access_token => "ZUVIMYCN_duM1UiX5A8S",
                               :password_salt => "ZUVIMYCN_duM1UiX5A8S",
                               :persistence_token => "b314b4447069448409c67e7a5781ba6222c14f5f00c609bb859c76df123078506924eb5f347afd2eb159529116ae99357796cb7a30b2bf9b382e9af48bae8020",
                               :crypted_password => "713ca29c00608ad4426e2b0c5e586740c608ab1230faac5ce734e64906c1329a1ed86e0e1a7e052a1bfa3fd0d8191e79a4fbdad758a0626aae840a4dab95dfdd",
                               :perishable_token => "A95QNR3SmNN7rhYHOSLQ")
    @valid_message = Message.create!(:text => "dummy text",:user => @valid_user)
  end
  
    
  # ruby Time.new returns                1278029284
  # in js, new Date().getTime(); returns 1278029295924
  # 
  it "should set current time on initialization" do
    timestamp_start = Time.new.to_f * 100
    timestamp = UserActivity.new("abc").timestamp
    timestamp_end = Time.new.to_f * 100
    
    timestamp.should > timestamp_start
    timestamp.should < timestamp_end 
  end
  
  it "should set timestamp specified in arguments of constructor" do
    UserActivity.new("abc",1278029295924).timestamp.should == 1278029295924
  end
  
  it "should have login name" do
    UserActivity.new("abc").login.should == "abc"
  end
  
  it "should show active users" do
    ua = UserActivity.new(@valid_user.login)    
    users = UserActivity.active_users
    users.should be_kind_of Array
    (users.include? @valid_user.login).should be_true
    
    # rewind timestamp for 11 seconds
    ua.timestamp -= 11 * 1000
    users = UserActivity.active_users    
    (users.include? @valid_user.login).should be_false
  end
  
  # it "should show latest activity of specified user" do
  #   UserActivity.latest_activity_of(@valid_user.login).should be_nil or be_kind_of UserActivity
  # end

  after(:all) do
    @valid_user.destroy if @valid_user
    @valid_message.destroy if @valid_message
  end  
end

