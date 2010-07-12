class Message < ActiveRecord::Base
  belongs_to :user
  validates_presence_of :user
  
  def to_json(*a)
    {
      'username'     => self.user.login,
      'timestamp'    => self.updated_at.to_i * 1000,
      'type'         => "msg",
      'text'         => self.text
    }.to_json(*a)
  end
  
  def self.json_create(o)
    new(*o['data'])
  end
end