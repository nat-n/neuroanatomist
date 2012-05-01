class Region < ActiveRecord::Base
  has_and_belongs_to_many :region_sets
  has_many :region_definitions
  has_many :shape_sets, :through => :region_definitions
end
