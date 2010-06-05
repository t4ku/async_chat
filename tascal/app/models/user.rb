class User < ActiveRecord::Base
  acts_as_authentic do |c|
    
    c.perishable_token_valid_for = 10.minutes
    # for available options see documentation in: Authlogic::ActsAsAuthentic
  end # block optional
end
