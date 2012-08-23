class Permission < ActiveRecord::Base
  belongs_to :user
  belongs_to :permitted, :polymorphic => true
  attr_accessible :thing_id, :user_id
  
  
  
end
