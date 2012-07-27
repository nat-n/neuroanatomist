class Tag < ActiveRecord::Base
  belongs_to :thing
  has_and_belongs_to_many :resource
  has_many :ratings
  
end
