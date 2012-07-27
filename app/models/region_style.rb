class RegionStyle < ActiveRecord::Base
  belongs_to :perspective
  belongs_to :region
  
end
