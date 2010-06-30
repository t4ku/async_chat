#
require "spec/spec_helper"

describe Sinatra::ArMySql do
  before(:all) do
    @valid_user = User.create!(:email => "spec_user_001@example.com",
                               :login => "spec_user_001",
                               :single_access_token => "ZUVIMYCN_duM1UiX5A8S",
                               :password_salt => "ZUVIMYCN_duM1UiX5A8S",
                               :persistence_token => "b314b4447069448409c67e7a5781ba6222c14f5f00c609bb859c76df123078506924eb5f347afd2eb159529116ae99357796cb7a30b2bf9b382e9af48bae8020",
                               :crypted_password => "713ca29c00608ad4426e2b0c5e586740c608ab1230faac5ce734e64906c1329a1ed86e0e1a7e052a1bfa3fd0d8191e79a4fbdad758a0626aae840a4dab95dfdd",
                               :perishable_token => "A95QNR3SmNN7rhYHOSLQ")
    
    class ArMySqlUse;include Sinatra::ArMySql;end
    @test_instance = ArMySqlUse.new
  end
  
  it "should validate user with their single_access_token" do
    @test_instance.authenticated?(@valid_user.single_access_token).should be_true
  end
  
  after(:all) do
    if @valid_user
      @valid_user.destroy
    end
  end
end
