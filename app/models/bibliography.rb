class Bibliography < ActiveRecord::Base
  belongs_to :referencable, :polymorphic => true
  has_and_belongs_to_many :resources
  has_many :tags, :through => :resources
  
end
