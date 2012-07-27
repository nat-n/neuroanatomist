class RegionSet < ActiveRecord::Base
  has_and_belongs_to_many :regions
  has_many :perspectives
  
end
